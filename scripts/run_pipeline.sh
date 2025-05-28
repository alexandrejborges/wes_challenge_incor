#!/bin/bash
set -euo pipefail

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

mkdir -p logs

echo "========== [1] Running Mosdepth =========="
for CRAM in data/*.cram; do
  SAMPLE=$(basename "$CRAM" .cram)
  echo "→ Running Mosdepth for $SAMPLE"
  bash scripts/coverage_mosdepth.sh "$SAMPLE" | tee "logs/${SAMPLE}_mosdepth.log"
done

echo "========== [2] Exploratory Analysis + Histogram (R) =========="
for BED_GZ in results/*.regions.bed.gz; do
  SAMPLE=$(basename "$BED_GZ" .regions.bed.gz)
  echo "→ Exploratory coverage analysis for $SAMPLE"
  Rscript scripts/coverage_summary_and_histogram.R "$BED_GZ" > "logs/${SAMPLE}_exploratory_analysis.log" 2>&1
done

echo "========== [3] Genetic Sex Inference (R) =========="
for SUMMARY in results/*.mosdepth.summary.txt; do
  SAMPLE=$(basename "$SUMMARY" .mosdepth.summary.txt)
  echo "→ Inferring genetic sex for $SAMPLE"
  Rscript scripts/sex_inference.R "$SAMPLE" > "logs/${SAMPLE}_chrXY_coverage.log" 2>&1
done

echo "========== [4] Converting CRAM to BAM =========="
bash scripts/convert_cram_to_bam.sh | tee logs/step4_convert_cram_to_bam.log

echo "========== [5] Estimating Contamination with verifyBamID =========="

# Handle Conda env switching with fallback
source ~/miniconda3/etc/profile.d/conda.sh

echo "→ Activating verifybamid_env..."
set +u
conda deactivate || true
set -u
conda activate verifybamid_env

bash scripts/contamination_verifybamid.sh | tee logs/step5_verifybamid.log

echo "→ Re-activating wes_qc_env..."
set +u
conda deactivate || true
set -u
conda activate wes_qc_env

echo "========== Pipeline completed successfully =========="

if grep -q "Error" logs/*.log; then
  echo "[WARNING] Errors were found in the log files. Please review."
else
  echo "[OK] All steps completed without errors."
fi
