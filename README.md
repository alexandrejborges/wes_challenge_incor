# WES-QC: Whole Exome Sequencing Quality Control Pipeline
![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)  
Bioinformatic challenge : Automated quality control pipeline for Whole Exome Sequencing (WES) data - Desafio Técnico Bioinformata


# WES Quality Control Pipeline

Pipeline automatizado de controle de qualidade para dados de Whole Exome Sequencing (WES), com foco no cálculo de cobertura, inferência de sexo genético e estimativa de contaminação. Este projeto faz parte de um desafio técnico com base na amostra NA06994 do 1000 Genomes Project.

## 🔬 Amostra utilizada

- **Nome**: NA06994
- **Origem**: Projeto 1000 Genomes – CEU
- **Formato**: `.cram` + `.crai`
- **Referência**: GRCh38_full_analysis_set_plus_decoy_hla.fa

---

## 📁 Estrutura do repositório

Este projeto implementa um pipeline automatizado de controle de qualidade para dados de Whole Exome Sequencing (WES), com base em arquivos públicos do 1000 Genomes Project. A amostra utilizada (NA06994) foi processada para avaliar a qualidade do sequenciamento por meio de:  
Cálculo da cobertura genômica nas regiões exônicas  
Geração de métricas de profundidade e porcentagem de regiões ≥10x e ≥30x  
Visualização gráfica da distribuição de cobertura por cromossomo  
O pipeline foi construído em ambiente Linux, com scripts reprodutíveis em Bash e R, e uso de ferramentas amplamente adotadas como mosdepth, samtools e ggplot2.


mosdepth  
samtools  
wget, gunzip  
R, ggplot2, dplyr, readr  
Ambiente Conda (via environment.yaml)


## Author
Alexandre Junio Borges Araujo  
📧 alexandrejunio@usp.br
📍 São Paulo, SP, Brasil  
▶️ LinkedIn: https://www.linkedin.com/in/alexandre-borges-57bb14150/
