#!/bin/bash
set -e

# =============================================================
# Script Name: coverage_mosdepth.sh
# Author: Alexandre J. Borges
# Description:
#   Computes coverage over exonic target regions using mosdepth.
# =============================================================

# Input paths
CRAM="data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
BED="data/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"
OUT_PREFIX="results/NA06994"
REF="data/GRCh38_full_analysis_set_plus_decoy_hla.fa"

# Run mosdepth
echo "[$(date)] Starting coverage calculation with mosdepth..."
echo "Using 4 threads and reference: $REF"
mosdepth -t 4 --fasta "$REF" --by "$BED" "$OUT_PREFIX" "$CRAM"
echo "[$(date)] Coverage calculation completed successfully."
