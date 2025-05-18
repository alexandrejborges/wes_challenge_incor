#!/bin/bash
set -euo pipefail

# =============================================================
# Script Name: contamination_verifybamid.sh
# Author: Alexandre J Borges
# Project: WES-QC: Whole Exome Sequencing Quality Control Pipeline
# Description:
#   This script performs contamination estimation for multiple WES BAM files
#   using verifyBamID v1.1.3. It filters a HapMap VCF for common biallelic SNPs,
#   indexes BAMs if needed, executes verifyBamID per sample, and saves outputs.
# =============================================================


VCF_ORIG="data/hapmap_3.3.hg38.vcf.gz"
VCF_FILTERED="data/hapmap_filtered.vcf.gz"

# Step 0 – Filter VCF only once
if [ ! -f "$VCF_FILTERED" ]; then
  echo "[$(date)] Filtering original VCF for common biallelic SNPs..."
  bcftools view -m2 -M2 -v snps "$VCF_ORIG" | \
    bcftools filter -i 'AF>0.05 && AF<0.95' -Oz -o "$VCF_FILTERED"
  bcftools index "$VCF_FILTERED"
  echo "[$(date)] Filtered VCF saved to $VCF_FILTERED"
else
  echo "[$(date)] Filtered VCF already exists. Skipping filtering."
fi

# Step 1 – Loop over all BAM samples in data/
for BAM in data/*.bam; do
  SAMPLE=$(basename "$BAM" .bam)
  OUT_PREFIX="results/${SAMPLE}_verifybam"
  LOG_FILE="logs/verifybamid_${SAMPLE}.log"

  echo "[$(date)] Starting sample: $SAMPLE"

  # Check for BAM index (.bai)
  if [ ! -f "${BAM}.bai" ] && [ ! -f "${BAM%.bam}.bai" ]; then
    echo "[$(date)] Creating BAM index for $SAMPLE..."
    samtools index "$BAM"
  fi

  # Skip if result already exists
  SELFSM="${OUT_PREFIX}.selfSM"
  if [ -f "$SELFSM" ]; then
    echo "[$(date)] Result already exists for $SAMPLE. Skipping."
    continue
  fi

  echo "[$(date)] Running verifyBamID for $SAMPLE..."
  verifyBamID \
    --vcf "$VCF_FILTERED" \
    --bam "$BAM" \
    --out "$OUT_PREFIX" \
    --ignoreRG \
    --precise \
    --maxDepth 100 \
    2>&1 | tee "$LOG_FILE"

  if [ -f "$SELFSM" ]; then
    echo "[$(date)] Completed: $SELFSM"
  else
    echo "[$(date)] ERROR: Output file not generated for $SAMPLE"
    exit 1
  fi

done

echo "[$(date)] All analyses completed."
