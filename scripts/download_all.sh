#!/bin/bash
set -euo pipefail

# =============================================================
# Script Name: download_all.sh
# Author: Alexandre J. Borges
# Description:
#   Script to download public files required for the WES pipeline:
#     - GRCh38 reference genome (with decoy and HLA)
#     - CRAM and CRAI files for sample NA06994 (1000 Genomes)
#     - BED file with exome target regions (Twist Exome v2.0.2)
#     - VCF and index file from HapMap 3.3 (hg38 version)
##   Also performs:
#     - FASTA indexing using samtools
#     - File integrity check using md5sum
#
   Input:
#     - None (files are downloaded automatically)
#
#   Output:
#     - Files in: data/
# =============================================================

# Create required directories
mkdir -p data logs

# Redirect all output to log file
LOG_FILE="logs/download_log.txt"
exec > >(tee "$LOG_FILE") 2>&1

echo "[$(date)] Starting download script..."

cd data

# 1. Download GRCh38 reference genome
echo "[$(date)] Downloading reference genome (GRCh38 + decoy + HLA)..."
wget -c --progress=bar:force https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

echo "[$(date)] Indexing reference genome..."
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa

# 2. Download CRAM and CRAI files for sample NA06994
echo "[$(date)] Downloading alignment files (CRAM and CRAI)..."
wget -c --progress=bar:force http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram
wget -c --progress=bar:force http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai

# 3. Download BED file for exome regions
echo "[$(date)] Downloading BED file (Twist Exome v2.0.2)..."
wget -c --progress=bar:force https://www.twistbioscience.com/sites/default/files/resources/2022-12/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed

# 4. Download VCF file and index (HapMap 3.3, hg38)
echo "[$(date)] Downloading VCF file and its index (HapMap 3.3, hg38)..."
wget -c --progress=bar:force https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz
wget -c --progress=bar:force https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi

# 5. Check file integrity
echo "[$(date)] Verifying file integrity with MD5..."

CRAM_HASH="3d8d8dc27d85ceaf0daefa493b8bd660"
CRAI_HASH="15a6576f46f51c37299fc004ed47fcd9"
BED_HASH="c3a7cea67f992e0412db4b596730d276"

CRAM_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
CRAI_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai"
BED_FILE="hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"

echo "$CRAM_HASH  $CRAM_FILE" | md5sum -c -
echo "$CRAI_HASH  $CRAI_FILE" | md5sum -c -
echo "$BED_HASH  $BED_FILE"   | md5sum -c -

cd ..
echo "[$(date)] Download, indexing and verification completed successfully!"

