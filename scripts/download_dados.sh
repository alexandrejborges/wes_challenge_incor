#!/bin/bash
set -e
(

#Diretório de destino
cd "data"

#Arquivos do 1000 Genomes
echo "Baixando arquivos do 1000 Genomes..."
wget -c  --progress=bar:force http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram
wget -c  --progress=bar:force http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai

#Arquivo BED das regiões exônicas (Twist Exome 2.0)
echo "Baixando arquivo BED da Twist Bioscience..."
wget -c  --progress=bar:force https://www.twistbioscience.com/sites/default/files/resources/2022-12/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed

#Verificação de integridade com md5sum
echo "Verificando integridade dos arquivos baixados..."

#Hashes esperados
CRAM_HASH="3d8d8dc27d85ceaf0daefa493b8bd660"
CRAI_HASH="15a6576f46f51c37299fc004ed47fcd9"
BED_HASH="c3a7cea67f992e0412db4b596730d276"

#Calculando hashes
CRAM_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram"
CRAI_FILE="NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai"
BED_FILE="hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed"

echo "$CRAM_HASH  $CRAM_FILE" | md5sum -c -
echo "$CRAI_HASH  $CRAI_FILE" | md5sum -c -
echo "$BED_HASH  $BED_FILE"  | md5sum -c -

#Voltar à raiz do projeto
cd ../

echo "!!! Download e verificação concluídos com sucesso!"

) 2>&1 | tee logs/download_log.txt
