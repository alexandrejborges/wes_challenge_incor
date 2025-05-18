set -euo pipefail

# ==============================================================================
# Script: convert_cram_to_bam.sh
# Author: Alexandre J Borges
# Description: Converts all .cram files in the /data directory to .bam and .bai
# ==============================================================================

# Directories
DATA_DIR="data"
LOG_DIR="logs"
REF="${1:-data/GRCh38_full_analysis_set_plus_decoy_hla.fa}"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

# Loop through all .cram files
for CRAM in "$DATA_DIR"/*.cram; do
  SAMPLE=$(basename "$CRAM" .cram)
  BAM_OUT="$DATA_DIR/${SAMPLE}.bam"
  LOG_FILE="$LOG_DIR/${SAMPLE}_convert.log"

  # Skip if BAM already exists
  if [[ -f "$BAM_OUT" ]]; then
    echo "BAM already exists for $SAMPLE — skipping conversion."
    continue
  fi

  # Checks
  if [[ ! -f "$CRAM" ]]; then
    echo "CRAM file not found: $CRAM" >&2
    exit 1
  fi
  if [[ ! -f "$REF" ]]; then
    echo "Reference file not found: $REF" >&2
    exit 1
  fi

  echo "Converting $SAMPLE..."
  {
    echo "[$(date)] Starting CRAM to BAM conversion: $CRAM"
    samtools view -@ 18 -b -T "$REF" -o "$BAM_OUT" "$CRAM"
    echo "[$(date)] Indexing BAM: $BAM_OUT"
    samtools index "$BAM_OUT"
    echo "[$(date)] Conversion and indexing completed successfully."
  } 2>&1 | tee "$LOG_FILE"

  echo "BAM generated: $BAM_OUT"
done

echo "All CRAM files have been converted."
