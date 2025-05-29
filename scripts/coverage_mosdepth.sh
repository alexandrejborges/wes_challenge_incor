#!/bin/bash
set -euo pipefail

# =============================================================
# Script Name: coverage_mosdepth.sh
# Author: Alexandre J. Borges
# Description:
#   Computes coverage over exonic target regions using mosdepth.
# =============================================================

# Checks if all 3 arguments were provided
if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <CRAM_file> <BED_file> <FASTA_file>"
  exit 1
fi

# Arguments
CRAM="$1"
BED="$2"
REF="$3"

# Checks if all files exists
[[ ! -f "$CRAM" ]] && { echo "ERROR: CRAM not found: $CRAM"; exit 1; }
[[ ! -f "$BED" ]] && { echo "ERROR: BED not found: $BED"; exit 1; }
[[ ! -f "$REF" ]] && { echo "ERROR: FASTA not found: $REF"; exit 1; }

#  Samples name
SAMPLE=$(basename "$CRAM" .cram)
OUT_PREFIX="results/${SAMPLE}"

# Executa o mosdepth
echo "[$(date)] Running Mosdepth for $SAMPLE"
echo "→ Using BED: $BED"
echo "→ Using Reference: $REF"
echo "→ Output Prefix: $OUT_PREFIX"

mosdepth -t 4 --fasta "$REF" --by "$BED" "$OUT_PREFIX" "$CRAM"

echo "[$(date)] Coverage calculation completed for $SAMPLE"

