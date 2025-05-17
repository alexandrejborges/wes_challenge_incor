# WES-QC: Whole Exome Sequencing Quality Control Pipeline
![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)  
Bioinformatic challenge : Automated quality control pipeline for Whole Exome Sequencing (WES) data - Desafio Técnico Bioinformata

## Author
👨🏽‍💻 Alexandre Junio Borges Araujo  
📧 alexandrejunio@usp.br  
▶️ LinkedIn: https://www.linkedin.com/in/alexandre-borges-57bb14150/

# WES Quality Control Pipeline

Pipeline automatizado de controle de qualidade para dados de Whole Exome Sequencing (WES), com foco no cálculo de cobertura, inferência de sexo genético e estimativa de contaminação. Este projeto faz parte de um desafio técnico com base na amostra NA06994 do 1000 Genomes Project.

## 🔬 Amostra utilizada

- **Nome**: NA06994
- **Origem**: Projeto 1000 Genomes – CEU
- **Formato**: `.cram` + `.crai`
- **Referência**: GRCh38_full_analysis_set_plus_decoy_hla.fa

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


## Criação dos ambientes necessários  
* conda env create -f environment.yaml (ambiente principal)  
* conda env create -f environment_verifybamid.yaml  (ambiente para usar o verifybamID)
  
Foi criado um ambiente exclusivo para usar o verifybamID devido sua necessidade de depêndencias específicas que podem conflitar com as utilizadas no ambiente principal.

---


## Etapa 3 — Verificação de Contaminação
O análisde de contaminação foi realizada com verifyBamID. Essa escolha se baseou na robustez estatística (inferência Bayesiana otimizada), adequação ao tipo de dado, e uso amplo na comunidade científica. Mais informações poderão se checadas em Jun G. et al. (2012). DOI: 10.1016/j.ajhg.2012.09.004.  

Como o verifyBamID necessita de arquivos .bam. Foram realizados os dois processos consecutivos:  
* Conversão de arquivos _.cram_ para _.bam_ com indexação  
* Verificação de contaminação genômica com _verifyBamID2_  

Todos os scripts se encontram no diretório scripts/. As saídas são organizadas em data/, logs/ e results/.

### 3.1 Conversão de CRAM para BAM
Arquivos .cram de amostras de exoma são convertidos para .bam com uso de referência genômica completa. Cada .bam é também indexado (.bai) e os logs são salvos separadamente.

**Ambiente:**  
wes_qc_env

**Script:**  
scripts/convert_cram_to_bam.sh

**Requisitos:**  
samtools ≥ v1.10  
Arquivo FASTA de referência com .fai (ex: GRCh38_full_analysis_set_plus_decoy_hla.fa)

**Estrutura:**  
├── data/  
│   ├── NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram  
│   ├── GRCh38_full_analysis_set_plus_decoy_hla.fa  
│   ├── GRCh38_full_analysis_set_plus_decoy_hla.fa.fai  
│   ├── NA06994.bam  
│   └── NA06994.bam.bai  
│  
├── logs/  
│   └── NA06994_convert.log

**Execução:**   
./scripts/convert_cram_to_bam.sh

**Saídas esperadas:**
* data/<sample>.bam
* data/<sample>.bam.bai
* logs/<sample>_convert.log
  
### 3.2 Verificação de Contaminação com verifyBamID
Utiliza verifyBamID para estimar contaminação com base em variantes de um VCF de referência populacional. Utiliza também um arquivo .bed das regiões exônicas.

**Ambiente:**  
verifybamID_env

**Script:**  
scripts/contamination_verifybamid.sh

**Estrutura:**  
├── data/  
│   ├── NA06994.bam  
│   ├── NA06994.bam.bai  
│   ├── hapmap_filtered.vcf.gz  
│   ├── hapmap_filtered.vcf.gz.csi  
│   ├── hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed  
│   └── GRCh38_full_analysis_set_plus_decoy_hla.fa  
│  
├── results/  
│   ├── NA06994_verifybam.selfSM  
│   └── NA06994_verifybam.depthSM  
│  
├── logs/  
│   └── verifybamid_NA06994.log

  
**Execução:**  
./scripts/contamination_verifybamid.sh <sample_name>

**Saídas esperadas:**
* results/<sample>_verifybam.selfSM
* results/<sample>_verifybam.depthSM
* logs/verifybamid_<sample>.log

**Arquivos gerados na amostra NA06994:**  
NA06994_verifybam.depthSM: Este arquivo registra a profundidade de cobertura (DP) da amostra em cada posição do VCF analisado. É útil para diagnósticos e para entender a distribuição da profundidade nas regiões genotipadas.  

NA06994_verifybam.selfSM: Este arquivo contém as estimativas de contaminação genômica e ancestralidade da amostra, com base na comparação entre o BAM analisado e o painel de variantes de referência (VCF). A coluna _FREEMIX_ determina a fração estimada de contaminação.  

**CONCLUSÃO:** O valor de  valor de 0.00035, que indica uma contaminação praticamente nula
