#!/bin/bash
set -e

# Caminhos
CRAM="data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
BED="data/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"
OUT_PREFIX="results/NA06994"
REF="data/GRCh38_full_analysis_set_plus_decoy_hla.fa"
LOG_FILE="logs/cobertura_mosdepth.log"

# Rodar mosdepth e salvar log
{
  echo "[$(date)] Iniciando cálculo de cobertura com mosdepth..."
  echo "Usando 4 threads e referência: $REF"
  mosdepth -t 4 --fasta "$REF" --by "$BED" "$OUT_PREFIX" "$CRAM"
  echo "[$(date)] Cálculo de cobertura concluído com sucesso."
}  2>&1 | tee "$LOG_FILE"
