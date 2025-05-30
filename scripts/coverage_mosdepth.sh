#!/bin/bash
set -euo pipefail

# =============================================================
# Script Name: coverage_mosdepth.sh
# Author: Alexandre J. Borges
# Description:
#   Computes coverage over exonic target regions using mosdepth.
# =============================================================

# Automatically find the CRAM file (expects only one)
CRAM=$(find data/ -maxdepth 1 -name "*.cram" | head -n 1)
[[ -z "$CRAM" ]] && { echo "ERROR: No CRAM file found in data/"; exit 1; }

# Automatically find the BED file
BED=$(find data/ -maxdepth 1 -name "*.bed" | head -n 1)
[[ -z "$BED" ]] && { echo "ERROR: No BED file found in data/"; exit 1; }

# Automatically find the FASTA reference file
REF=$(find data/ -maxdepth 1 -name "*.fa" | head -n 1)
[[ -z "$REF" ]] && { echo "ERROR: No FASTA file found in data/"; exit 1; }

# Extract sample name from CRAM filename
SAMPLE=$(basename "$CRAM" .cram)
OUT_PREFIX="results/${SAMPLE}"

# Display file paths
echo "→ CRAM: $CRAM"
echo "→ BED: $BED"
echo "→ Reference: $REF"
echo "→ Output Prefix: ${OUT_PREFIX}_mosdepth"

# Run Mosdepth
# If THREADS is defined, use it; otherwise run without -t
if [[ -n "${THREADS:-}" ]]; then
  mosdepth -t "$THREADS" --fasta "$REF" --by "$BED" "$OUT_PREFIX" "$CRAM"
else
  mosdepth --fasta "$REF" --by "$BED" "$OUT_PREFIX" "$CRAM"
fi

echo "[$(date)] Coverage calculation completed for $SAMPLE"
