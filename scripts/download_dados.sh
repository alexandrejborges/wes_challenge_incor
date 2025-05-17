# =============================================================
# Script Name: download_all.sh
# Author: Alexandre J. Borges
# Last Modified: 2025-05-17
# Description:
#   Script to download public files required for the WES pipeline:
#     - GRCh38 reference genome (with decoy and HLA)
#     - CRAM and CRAI files for sample NA06994 (1000 Genomes)
#     - BED file with exome target regions (Twist Exome v2.0.2)
#
#   Also performs:
#     - FASTA indexing using samtools
#     - File integrity check using md5sum
#     - Logging to logs/download_log.txt
#
#   Input:
#     - None (files are downloaded automatically)
#
#   Output:
#     - Files in: data/
#     - Log file: logs/download_log.txt
# =============================================================

#!/bin/bash
set -e
(
# Criar diretório de destino se não existir
mkdir -p data
cd data

# 1. Download do genoma de referência
echo " Baixando o genoma de referência (GRCh38 + decoy + HLA)..."
wget -c --progress=bar:force \
  https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa

echo "Indexando o arquivo fasta..."
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa

# 2. Download da amostra CRAM e CRAI
echo " Baixando arquivos de alinhamento (CRAM e CRAI)..."
wget -c --progress=bar:force \
  http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram

wget -c --progress=bar:force \
  http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai

# 3. Download do arquivo BED das regiões exônicas
echo "Baixando arquivo BED (Twist Exome v2.0.2)..."
wget -c --progress=bar:force \
  https://www.twistbioscience.com/sites/default/files/resources/2022-12/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed

# 4. Verificação de integridade dos arquivos
echo "Verificando integridade dos arquivos com MD5..."

# Hashes esperados
CRAM_HASH="3d8d8dc27d85ceaf0daefa493b8bd660"
CRAI_HASH="15a6576f46f51c37299fc004ed47fcd9"
BED_HASH="c3a7cea67f992e0412db4b596730d276"

# Arquivos correspondentes
CRAM_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
CRAI_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai"
BED_FILE="hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"

# Verificação
echo "$CRAM_HASH  $CRAM_FILE" | md5sum -c -
echo "$CRAI_HASH  $CRAI_FILE" | md5sum -c -
echo "$BED_HASH  $BED_FILE" | md5sum -c -

cd ../
echo " Download, indexação e verificação concluídos com sucesso!"

) 2>&1 | tee logs/download_log.txt
