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

## 📁 Peparação e Estrutura repositório
Este repositório organiza os arquivos e scripts utilizados em um pipeline de controle de qualidade e análise exploratória. A seguir, descreve-se a estrutura e a função de cada diretório e os principais arquivos:

wes_challenge_incor/  
├── data/                        
├── environment.yaml             
├── environment_verifybamid.yaml  
├── logs/                        
├── results/                      
├── scripts/                   
└── README.md                       

**onde:**  
**data/**: Contém os dados de entrada utilizados no pipeline, incluindo arquivos .cram, .bam, .vcf, .bed e o genoma de referência em formato .fa.  
**environment.yaml**: Arquivo para criação do ambiente Conda principal, com as dependências gerais do pipeline (R, mosdepth, samtools etc.).  
**environment_verifybamid.yaml**: Ambiente específico contendo apenas os pacotes necessários para execução do verifyBamID2.  
**logs/**: Diretório onde são armazenados os arquivos de log gerados por cada etapa, facilitando a verificação e depuração do pipeline.  
**results/**: Diretório com as saídas das análises, incluindo tabelas, gráficos, logs de inferência de sexo, e resultados do verifyBamID2.  
**scripts/**: Scripts automatizados em Bash e R responsáveis por cada etapa da análise (download, cobertura, conversão, visualização etc.).  
**README.md**: Documento com instruções, estrutura e explicações sobre o funcionamento e execução do pipeline.

## Criação dos ambientes necessários  
* [environment.yaml](environment.yaml) — Ambiente principal  
* [environment_verifybamid.yaml](environment_verifybamid.yaml) — Ambiente para uso do verifyBamID
  
Foi criado um ambiente exclusivo para usar o verifybamID devido sua necessidade de depêndencias específicas que podem conflitar com as utilizadas no ambiente principal.

---
## Etapa 2 — Inferência do Sexo Genético
A inferência de sexo genético foi realizada com base na cobertura dos cromossomos sexuais, utilizando os arquivos de saída do _mosdepth_ (_.mosdepth.summary.txt_). Diferentemente de abordagens baseadas exclusivamente no exoma, este método considera a cobertura de todos os cromossomos (X e Y) em comparação à cobertura média dos autossomos. A classificação é realizada por meio de limiares empíricos fixos aplicados à razão entre cobertura dos cromossomos sexuais e autossomos, sem uso de inferência bayesiana, como ocorre em ferramentas como o _seGMM_ (Liu et al. 2022).

Todos os scripts estão organizados no diretório scripts/. As saídas são organizadas em logs/ e results/.

**Ambiente:**  
wes_qc_env

**Script:**  
scripts/sex_inference.R

**Requisitos:**  
R ≥ 4.0  
Pacotes: ggplot2, readr, dplyr, stringr  
Arquivo de entrada: results/<sample>.mosdepth.summary.txt

**Lógicas de Classificação Utilizadas:**  
chrX ≈ 2× autosomos, chrY ≈ 0 =	Female (XX)  
chrX ≈ 1× autosomos, chrY ≈ 1× autosomos	= Male (XY)  
chrX ≈ 2× autosomos, chrY elevado	= Possível aneuploidia (XXY)  
chrX ≈ 1× autosomos, chrY ≈ 0	= Possível aneuploidia (X0)  
Caso intermediário ou ambíguo	= Indeterminado  

x_female_lower_threshold <- 0.8  
x_male_upper_threshold <- 0.6  
y_male_lower_threshold <- 0.1  

**Estrutura:**  
├── results/  
│   ├── NA06994.mosdepth.summary.txt  
│   ├── NA06994_chrXY_coverage.png  
│  
├── logs/  
│   └── NA06994_chrXY_coverage.log

**Execução:**  
Rscript scripts/sex_inference.R <sample_name>

**Saídas esperadas:**  
* results/NA06994_chrXY_coverage.png: Gráfico de barras com a cobertura média por cromossomo.  
* results/NA06994_chrXY_coverage.log: Log contendo razão de cobertura, médias e sexo inferido.

**Resultaddos gerados na amostra NA06994:**  
![Cobertura por cromossomo - NA06994](results/NA06994_chrXY_coverage.png)  
=== Genetic Sex Inference ===  
Sample: NA06994  
Average autosome coverage: 2.92  
chrX coverage: 1.44 ( 0.49 x autosomes)  
chrY coverage: 0.66 ( 0.23 x autosomes)  
Inferred sex: Male (XY)  

**CONCLUSÃO:** A razão de cobertura X/A de 0,5 indica a presença de um único cromossomo X, enquanto a razão Y/A, ainda que baixa, sugere a presença do cromossomo Y. Com base nesses dados, conclui-se que a amostra é proveniente de um indivíduo com sexo genético masculino.

---
## Etapa 3 — Verificação de Contaminação
O análisde de contaminação foi realizada com verifyBamID. Essa escolha se baseou na robustez estatística (inferência Bayesiana otimizada), adequação ao tipo de dado, e uso amplo na comunidade científica. Mais informações poderão se checadas em Jun G. et al. (2012)

Como o verifyBamID necessita de arquivos .bam. Foram realizados os dois processos consecutivos:  
* Conversão de arquivos _.cram_ para _.bam_ com indexação  
* Verificação de contaminação genômica com _verifyBamID2_  

Todos os scripts estão organizados no diretório scripts/. As saídas são organizadas em logs/ e results/.

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

**CONCLUSÃO:** O valor de _FREEMIX_ foi de 0.00035, indicando uma contaminação praticamente nula

---
## Referências:
Liu, S., Zeng, Y., Wang, C., Zhang, Q., Chen, M., Wang, X., ... & Bu, F. (2022). seGMM: A new tool for gender determination from massively parallel sequencing data. Frontiers in Genetics, 13, 850804.  
Jun, G., Flickinger, M., Hetrick, K. N., Romm, J. M., Doheny, K. F., Abecasis, G. R., ... & Kang, H. M. (2012). Detecting and estimating contamination of human DNA samples in sequencing and array-based genotype data. The American Journal of Human Genetics, 91(5), 839-848.
