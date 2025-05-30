# WES-QC: Controle de Qualidade para Sequenciamento de Exoma Completo
![Badge em Desenvolvimento](http://img.shields.io/static/v1?label=STATUS&message=EM%20DESENVOLVIMENTO&color=GREEN&style=for-the-badge)  

# Pipeline de Controle de Qualidade WES

Pipeline automatizado de controle de qualidade para dados de Whole Exome Sequencing (WES), com foco no cálculo de cobertura, inferência de sexo genético e estimativa de contaminação. Este projeto faz parte de um desafio técnico com base na amostra NA06994 do 1000 Genomes Project.

## Autor
👨🏽‍💻 Alexandre Junio Borges Araujo  
📧 alexandrejuniob96@gmail.com  
▶️ [LinkedIn/Alexandre_Borges](https://www.linkedin.com/in/alexandre-borges-57bb14150/)

## 🔬 Amostra utilizada
 
Este pipeline foi implementado utilizando a amostra descrita abaixo, porém sua estrutura automatizada permite a aplicação a qualquer outra amostra, desde que os arquivos de entrada exigidos estejam devidamente disponibilizados (ver seção: 'Preparação — Download dos arquivos necessários').

- **Nome**: NA06994
- **Origem**: Projeto 1000 Genomes – CEU
- **Formato**: `.cram` + `.crai`
- **Referência**: GRCh38_full_analysis_set_plus_decoy_hla.fa
---

## (Preparação) - Criação do diretório e configuração dos ambientes necessários  
Não é necessário clonar este repositório principal para executar o projeto. Basta executar o script [setup_project.sh](setup_project.sh), que irá configurar automaticamente o ambiente, criar a estrutura mínima de diretórios e baixar os scripts necessários para a execução do pipeline.

**Configuração dos ambientes necessários 🖥️:**  
* _wes_qc_env_ — r-base=4.2.2, r-ggplot2, r-dplyr, r-stringr, r-readr, r-data.table e mosdepth.
* _verifybamid_env_ — verifybamid.

**A estrutura mínima do diretório 📁:**    
wes_challenge_incor/  
├── data/                            
├── logs/                        
├── results/                                         
└── scripts/     

**Scripts necessários 📄:**  
└── scripts  
    ├── contamination_verifybamid.sh  
    ├── convert_cram_to_bam.sh  
    ├── coverage_mosdepth.sh  
    ├── coverage_summary_and_histogram.R  
    ├── download_all.sh  
    ├── run_pipeline.sh  
    └── sex_inference.R  

Informações detalhadas sobre os scripts podem ser encontradas nas próximas seções  

---
## (Preparação) — Download dos arquivos necessários
Para a execução do pipeline com a amostra NA06994, foram necessários de seis arquivos públicos obtidos a partir de repositórios oficiais. Ambos foram baixados com script abaixo e armazenados na pasta _data/_.

**Ambiente:**  
wes_qc_env  

**Diretório de Execução:**  
wes_challenge_incor

**Script:**  
[download_all.sh](scripts/download_all.sh)  
Execução: `./script/download_all.sh`

**Arquivo de alinhamento (.cram):** [GRCh38DH.20150826.CEU.exome.cram](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram)  
**Índice do alinhamento (.cram.crai):** [GRCh38DH.20150826.CEU.exome.cram.crai](http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000_genomes_project/data/CEU/NA06994/exome_alignment/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai)  
**Arquivo de regiões exônicas (.bed):** [hg38_exome_v2.0.2_targets_validated.re_annotated.bed](https://www.twistbioscience.com/sites/default/files/resources/2022-12/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed)  
**Genoma de referência (.fa):** [GRCh38_full_analysis_set_plus_decoy_hla.fa](https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/GRCh38_reference_genome/GRCh38_full_analysis_set_plus_decoy_hla.fa)  
**Arquivo Variant Call Format (.vcf):** [hapmap_3.3.hg38.vcf.gz](https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz)  
**Índice do VFC:** [hapmap_3.3.hg38.vcf.gz.tbi](https://storage.googleapis.com/genomics-public-data/resources/broad/hg38/v0/hapmap_3.3.hg38.vcf.gz.tbi)

A integridade dos arquivos baixados foi realizada por meio da comparação de seus hashes MD5 com as respectivas impressões digitais:

**Arquivo .cram:** 3d8d8dc27d85ceaf0daefa493b8bd660  
**Arquivo .cram.crai:** 15a6576f46f51c37299fc004ed47fcd9  
**Arquivo .bed:** c3a7cea67f992e0412db4b596730d276

**Resultados (log) gerados na amostra NA06994 [log.file](logs/download_log.txt):**  
Verificando integridade dos arquivos com MD5...  
NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram: OK  
NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai: OK  
hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed: OK  
Download, indexing and verification completed successfully!

---
## 🔁 Automação

O script [run_pipeline.sh](run_pipeline.sh) executa automaticamente todas as etapas do pipeline de controle de qualidade. Ele pode ser utilizado para processar múltiplas amostras e permite a definição do número de núcleos de processamento a ser utilizado (caso especificado).

### 🔧 O que ele faz:

1. Calcula a cobertura com o mosdepth para cada _.cram_ em _data/_  
2. Executa a análise exploratória de cobertura e gera histogramas com R  
3. Realiza a inferência de sexo genético com base na razão de cobertura dos cromossomos X e Y  
4. Converte arquivos _.cram_ para _.bam_ e gera os arquivos _.bai_  
5. Estima a contaminação usando _verifyBamID_
6. Identificação de possíveis erros
   
### ▶️ Como executar:
**Ambiente:**  
wes_qc_env 

**Diretório de Execução:**  
wes_challenge_incor

**Script:**  
[run_pipeline.sh](scripts/run_pipeline.sh)  
Execução: `./scripts/run_pipeline.sh <Número de núcleos de processamento>`

Cada etapa do pipeline é descrita a seguir e pode ser executada isoladamente!

---
## Análise de Cobertura do Exoma com Mosdepth 
Este pipeline realiza o cálculo da cobertura de regiões exônicas utilizando o software Mosdepth e em seguida (separadamente), a análise exploratória dos resultados em R.  

### Cálculo de Cobertura com Mosdepth
O cálculo da cobertura das regiões exônicas foi realizado utilizando como entrada o arquivo _.cram_ da amostra, o arquivo _.bed_ com as regiões-alvo do exoma e o genoma de referência completo (incluindo decoy e regiões HLA).

A execução foi feita via script _coverage_mosdepth.sh_, que inclui a instrução set -e para interromper automaticamente o pipeline em caso de erro, garantindo a integridade da análise.

**Ambiente:**  
wes_qc_env

**Script:**  
[coverage_mosdepth.sh](scripts/coverage_mosdepth.sh)

**Requisitos:**  
Mosdepth  
Arquivo `CRAM`: data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram  
Índice CRAI correspondente  
Referência: `data/GRCh38_full_analysis_set_plus_decoy_hla.fa`  
Regiões-alvo: `data/hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed`

**Estrutura Esperada para Execução:**  
wes_challenge_incor/  
├── data/  
│   ├── NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram       
│   ├── NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram.crai   
│   ├── GRCh38_full_analysis_set_plus_decoy_hla.fa               
│   ├── GRCh38_full_analysis_set_plus_decoy_hla.fa.fai           
│   └── hg38_exome_v2.0.2_targets_sorted_validated.re_annotated.bed  
│  
├── scripts/  
│   └── coverage_mosdepth.sh  
│  
├── results/  
│  
├── logs/   

**Execução:**  
`./scripts/coverage_mosdepth.sh`

**Saídas esperadas:**  
`results/NA06994.regions.bed.gz`: Profundidade por região exônica  
`results/NA06994.mosdepth.summary.txt`: Estatísticas resumidas de cobertura  
`results/NA06994.mosdepth.global.dist.txt`  
`results/NA06994.mosdepth.region.dist.txt `  
`results/NA06994.per-base.bed.gz`  
`results/NA06994.per-base.bed.gz.csi`  
`results/NA06994.regions.bed.gz.csi`  

**Resultaddos gerados na amostra NA06994 [log.file](logs/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome_mosdepth.log):**    
[Mon May 12 21:17:52 -03 2025] Iniciando cálculo de cobertura com mosdepth...  
Usando 4 threads e referência: data/GRCh38_full_analysis_set_plus_decoy_hla.fa  
[Mon May 12 21:20:04 -03 2025] Cálculo de cobertura concluído com sucesso.  

### Análise Exploratória da Cobertura
A análise exploratória foi realizada com funções nativas da linguagem R, utilizando como entrada o arquivo .bed.gz gerado pelo Mosdepth. O script calcula métricas estatísticas de cobertura e gera uma visualização gráfica da distribuição dos dados.

**Ambiente:**  
wes_qc_env

**Script:**  
[coverage_summary_and_histogram.R](scripts/coverage_summary_and_histogram.R)

**Requisitos:**  
R ≥ 4.0  
Pacotes: readr, dplyr, stringr, ggplot2  
Arquivo de entrada: results/NA06994.regions.bed.gz

**Estrutura Esperada para Execução:**  
wes_challenge_incor/  
├── results/  
│   └── NA06994.regions.bed.gz  
│  
├── scripts/  
│   └── exploratory_analysis_coverage.R  
│  
├── logs/         

**Execução:**
`Rscript scripts/exploratory_analysis_coverage.R results/NA06994.regions.bed.gz`

**Saídas esperadas:**
`results/exploratory_analysis_coverage.csv`   
`results/histogram_coverage.png`  
`logs/exploratory_analysis_coverage.log`  

**Resultaddos gerados na amostra NA06994[logfile](NA06994_exploratory_analysis.log):**  
[INFO] Loading input file: ../results/NA06994.regions.bed.gz  
[INFO] Calculating coverage statistics...  
[INFO] Summary written to: ../results/exploratory_analysis_coverage.csv  
========== Coverage Summary ==========  
metric      
Mean Depth:   64.16930  
Minimum Depth:    0.00000  
Maximum Depth: 3371.81000  
Regions with Coverage ≥ 10x (%):   71.76290  
Regions with Coverage ≥ 30x (%):   61.21708  

![Cobertura por cromossomo - NA06994](results/histogram_coverage.png)  

**CONCLUSÃO:**  
A amostra apresentou uma profundidade média de 64,17×, indicando cobertura robusta para análise de variantes em regiões exônicas. Além disso, 71,76% das regiões apresentaram cobertura igual ou superior a 10×, e 61,22% foram cobertas por pelo menos 30×, valores que indicam boa qualidade para chamadas de variantes com alta confiança. Apesar de adequada, a cobertura não é uniforme, o que reforça a importância de avaliar graficamente a distribuição.

---
## Inferência do Sexo Genético
A inferência de sexo genético foi realizada com base na cobertura dos cromossomos sexuais, utilizando os arquivos de saída do _mosdepth_ (_.mosdepth.summary.txt_). Diferentemente de abordagens baseadas exclusivamente no exoma, este método considera a cobertura de todos os cromossomos (X e Y) em comparação à cobertura média dos autossomos. A classificação é realizada por meio de limiares empíricos fixos aplicados à razão entre cobertura dos cromossomos sexuais e autossomos como ocorre em ferramentas como o seGMM (Liu et al. 2022). Entretanto, o seGMM também utiliza inferência bayesiana para melhor acurácia, o que não foi necessário nesse pipeline. 


**Ambiente:**  
wes_qc_env

**Script:**  
[sex_inference.R](scripts/sex_inference.R)

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

**Estrutura Esperada para Execução:**  
wes_challenge_incor/  
├── results/  
│   └── NA06994.mosdepth.summary.txt   
│  
├── scripts/  
│   └── sex_inference.R    
│  
├── logs/  

**Execução:**  
`Rscript scripts/sex_inference.R <sample_name>`

**Saídas esperadas:**  
* `results/NA06994_chrXY_coverage.png`: Gráfico de barras com a cobertura média por cromossomo.  
* `results/NA06994_chrXY_coverage.log`: Log contendo razão de cobertura, médias e sexo inferido.

**Resultaddos gerados na amostra NA06994[logfile](NA06994_chrXY_coverage.log):**  
![Cobertura por cromossomo - NA06994](results/NA06994_chrXY_coverage.png)  
=== Genetic Sex Inference ===  
Sample: NA06994  
Average autosome coverage: 2.92  
chrX coverage: 1.44 ( 0.49 x autosomes)  
chrY coverage: 0.66 ( 0.23 x autosomes)  
Inferred sex: Male (XY)  

**CONCLUSÃO:**  
A razão entre a cobertura do cromossomo X e os autossomos foi de 0,49, indicando a presença de apenas um cromossomo X. A cobertura observada no cromossomo Y foi de 0,23× em relação aos autossomos, sugerindo a presença do cromossomo Y. Com base nesses valores, a amostra NA06994 foi classificada como tendo sexo genético masculino (XY).

---
## Verificação de Contaminação verifyBamID.
O verifyBamID foi escolhido para a estimativa de contaminação por ser uma ferramenta amplamente validada para dados de sequenciamento humano, com desempenho eficiente na detecção de DNA exógeno. Seu algoritmo compara os alelos observados nos arquivos BAM com variantes conhecidas presentes em arquivos VCF públicos, como o HapMap 3.3, e estima a fração de contaminação (FREEMIX) com base em modelos estatísticos. Essa abordagem permite identificar níveis baixos de contaminação sem a necessidade de genótipos de controle, sendo especialmente adequada para análises automatizadas e em larga escala. Além disso, o verifyBamID apresenta baixa demanda computacional e compatibilidade com múltiplas amostras, o que o torna uma opção robusta para controle de qualidade inicial em pipelines de WES.

Como o verifyBamID necessita de arquivos .bam. Foram realizados os dois processos consecutivos:  
* Conversão de arquivos _.cram_ para _.bam_ com indexação  
* Verificação de contaminação genômica com _verifyBamID2_  

Todos os scripts estão organizados no diretório scripts/. As saídas são organizadas em logs/ e results/.

### Conversão de CRAM para BAM
Arquivos .cram de amostras de exoma são convertidos para .bam com uso de referência genômica completa. Cada .bam é também indexado (.bai) e os logs são salvos separadamente.

**Ambiente:**  
wes_qc_env

**Script:**  
[convert_cram_to_bam.sh](scripts/convert_cram_to_bam.sh)

**Requisitos:**  
samtools ≥ v1.10  
Arquivo CRAM: data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram   
Arquivo FASTA de referência com .fai (ex: GRCh38_full_analysis_set_plus_decoy_hla.fa)

**strutura Esperada para Execução:**  
wes_challenge_incor/  
├── data/  
│   ├── NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram      
│   ├── GRCh38_full_analysis_set_plus_decoy_hla.fa              
│   └── GRCh38_full_analysis_set_plus_decoy_hla.fa.fai         
│  
├── scripts/  
│   └── convert_cram_to_bam.sh                               
│  
├── results/                                                    
│  
├── logs/      

**Execução:**   
`./scripts/convert_cram_to_bam.sh`

**Saídas esperadas:**
* `data/_sample_.bam`
* `data/_sample_.bam.bai`
* `logs/convert_cram_to_bam.log`

**Resultaddos gerados na amostra NA06994[logfile](logs/step4_convert_cram_to_bam.log):**  
Converting NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome...  
[Sat May 17 21:33:45 -03 2025] Starting CRAM to BAM conversion: data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.cram  
[Sat May 17 21:34:52 -03 2025] Indexing BAM: data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.bam  
[Sat May 17 21:35:29 -03 2025] Conversion and indexing completed successfully.  
BAM generated: data/NA06994.alt_bwamem_GRCh38DH.20150826.CEU.exome.bam  
All CRAM files have been converted.  

### Verificação de Contaminação com verifyBamID


**Ambiente:**  
verifybamID_env

**Script:**  
[contamination_verifybamid.sh](scripts/contamination_verifybamid.sh)

**Requisitos:**
* verifyBamID ≥ v1.1.3  
* Arquivo BAM: data/NA06994.bam  
* Arquivo .bai: data/NA06994.bam.bai  
* Arquivo VCF filtrado com variantes bialélicas comuns: data/hapmap_filtered.vcf.gz  
* Índice .csi do VCF: data/hapmap_filtered.vcf.gz.csi  
* Arquivo BED com regiões-alvo do exoma (opcional, se usado no script):   

**Estrutura Esperada para Execução:**  
wes_challenge_incor/  
├── data/  
│   ├── NA06994.bam                            
│   ├── NA06994.bam.bai                         
│   ├── hapmap_filtered.vcf.gz                   
│   ├── hapmap_filtered.vcf.gz.csi                
│  
├── scripts/  
│   └── contamination_verifybamid.sh            
│  
├── results/                                    
│  
├── logs/      

  
**Execução:**  
`./scripts/contamination_verifybamid.sh`

**Saídas esperadas:**
* results/<sample>_verifybam.selfSM
* results/<sample>_verifybam.depthSM
* logs/

**Arquivos gerados na amostra NA06994 [logfile](logs/NA06994_verifybam.log):**  
NA06994_verifybam.depthSM: Este arquivo registra a profundidade de cobertura (DP) da amostra em cada posição do VCF analisado. É útil para diagnósticos e para entender a distribuição da profundidade nas regiões genotipadas.  

NA06994_verifybam.selfSM: Este arquivo contém as estimativas de contaminação genômica e ancestralidade da amostra, com base na comparação entre o BAM analisado e o painel de variantes de referência (VCF). A coluna _FREEMIX_ determina a fração estimada de contaminação.  

**CONCLUSÃO:**  
A amostra NA06994 apresentou uma estimativa de contaminação (_FREEMIX_) de 0,00035, ou seja, 0,035%. Esse valor está muito abaixo do limite de tolerância geralmente aceito (2%), indicando que não há evidência de contaminação significativa na amostra. Portanto, os dados podem ser considerados confiáveis para análises genômicas subsequentes.

---
## Referências:
Liu, S., Zeng, Y., Wang, C., Zhang, Q., Chen, M., Wang, X., ... & Bu, F. (2022). seGMM: A new tool for gender determination from massively parallel sequencing data. Frontiers in Genetics, 13, 850804.  
