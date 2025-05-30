#!/bin/bash

# =============================================================
# Script Name: run_pipeline.sh
# Author: Alexandre J. Borges
# Description:
#   Master script to run the WES-QC pipeline sequentially:
#     1. Calculate coverage with Mosdepth
#     2. Exploratory analysis + histogram (R)
#     3. Infer genetic sex from coverage summary
#     4. Convert CRAM to BAM
#     5. Estimate contamination with verifyBamID
# =============================================================

set -euo pipefail
trap 'echo "[ERROR] Step failed: $CURRENT_STEP at line $LINENO"; exit 1' ERR

LOG_FILE="logs/pipeline_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee "$LOG_FILE") 2>&1

mkdir -p logs

if [[ $# -eq 1 ]]; then
  export THREADS="$1"
  echo "Using $THREADS threads for supported steps."
else
  echo "THREADS not defined — using default behavior for each tool."
fi


CURRENT_STEP="Mosdepth"
echo "========== [1] Running Mosdepth =========="
for CRAM in data/*.cram; do
  SAMPLE=$(basename "$CRAM" .cram)
  echo "[$(date)] → Running Mosdepth for $SAMPLE"
  bash scripts/coverage_mosdepth.sh | tee "logs/${SAMPLE}_mosdepth.log"
  echo "[$(date)] [OK!] Mosdepth Calculation Finished: $SAMPLE"
done


CURRENT_STEP="Exploratory Coverage Analysis (R)"
echo "========== [2] Exploratory Analysis + Histogram (R) =========="
for BED_GZ in results/*.regions.bed.gz; do
  SAMPLE=$(basename "$BED_GZ" .regions.bed.gz)
  echo "[$(date)] → Exploratory coverage analysis for $SAMPLE"
  Rscript scripts/coverage_summary_and_histogram.R "$BED_GZ" > "logs/${SAMPLE}_exploratory_analysis.log" 2>&1
  echo "[$(date)] [OK!] Coverage Analysis Finished: $SAMPLE"
  echo "---------------------------------------------------"
done

CURRENT_STEP="Genetic Sex Inference (R)"
echo "========== [3] Genetic Sex Inference (R) =========="
for SUMMARY in results/*.mosdepth.summary.txt; do
  SAMPLE=$(basename "$SUMMARY" .mosdepth.summary.txt)
  echo "[$(date)] → Inferring genetic sex for $SAMPLE"
  Rscript scripts/sex_inference.R "$SAMPLE" > "logs/${SAMPLE}_chrXY_coverage.log" 2>&1
  echo "[$(date)] [OK!]Sex Inference Finished: $SAMPLE"
  echo "---------------------------------------------------"
done

CURRENT_STEP="Convert CRAM to BAM"
echo "========== [4] Converting CRAM to BAM =========="
bash scripts/convert_cram_to_bam.sh | tee logs/converted_cram_to_bam.log
echo "[$(date)] [OK!] Convertion Finished: $SAMPLE"
echo "---------------------------------------------------"

CURRENT_STEP="Estimate Contamination with verifyBamID"
echo "========== [5] Estimating Contamination with verifyBamID =========="

# Handle Conda env switching with fallback
source ~/miniconda3/etc/profile.d/conda.sh

echo "[$(date)] → Activating verifybamid_env..."
set +u
conda deactivate || true
set -u
conda activate verifybamid_env

bash scripts/contamination_verifybamid.sh | tee logs/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome_automation_verifybamid.log

echo "[$(date)] → Re-activating wes_qc_env..."
set +u
conda deactivate || true
set -u
conda activate wes_qc_env
echo "[$(date)] [OK!] Estimating Contamination Finished: $SAMPLE"
echo "---------------------------------------------------"
  
CURRENT_STEP="Final log check"
echo "========== Pipeline completed successfully =========="


ERROR_LINES=$(grep -i "error" logs/*.log | grep -v -E "genoError|error rate|no error" || true)

if [[ -n "$ERROR_LINES" ]]; then
  echo "[WARNING] The following log lines contain 'error':"
  echo "$ERROR_LINES"
else
  echo "[OK!] All steps completed successfully without reported errors."
fi
