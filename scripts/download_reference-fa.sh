#!/bin/bash
set -e
(

#Diretório de destino
cd data

#Arquivos referencia do 1000 genomas
echo "Baixando o genoma referencia..."
wget -c --progress=bar:force https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa


#Descompactando
#echo "Descompactando..."
#gunzip Homo_sapiens_assembly38.fasta.gz


#Indexacao do fasta
echo "Indexando o arquivo fasta..."
samtools faidx GRCh38_full_analysis_set_plus_decoy_hla.fa

#Voltar à raiz do projeto
cd ../

echo "!!! Download e Indexação concluídos com sucesso!"

) 2>&1 | tee logs/download_reference_log.txt
