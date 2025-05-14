#!/usr/bin/env Rscript

# Carregar pacotes necessários (instalar se não estiverem disponíveis)
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if (!requireNamespace("readr", quietly = TRUE)) install.packages("readr", repos = "http://cran.us.r-project.org")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr", repos = "http://cran.us.r-project.org")

library(ggplot2)
library(readr)
library(dplyr)

# Definir caminho do arquivo de entrada
bed_file <- "/home/alexandre/wes_challenge_incor/results/NA06994.regions.bed.gz"

# Leitura dos dados com nomes e tipos de colunas definidos
data <- read_tsv(
  bed_file,
  col_names = c("chr", "start", "end", "sample", "depth"),
  col_types = cols(
    chr = col_character(),
    start = col_integer(),
    end = col_integer(),
    sample = col_character(),
    depth = col_double()
  )
)

# Filtrar regiões com profundidade maior que zero
dados_filtred <- data %>%
  filter(depth > 0)

# Calcular profundidade média geral
depth_mean <- mean(data$depth, na.rm = TRUE)

# Gerar histograma da profundidade média
hist_graf <- ggplot(dados_filtred, aes(x = depth)) +
  geom_histogram(binwidth = 10, fill = "steelblue", color = "black") +
  geom_vline(xintercept = depth_mean, color = "black", linetype = "dashed", size = 1) +
  annotate(
    "text",
    x = depth_mean + 10,
    y = Inf,
    label = paste0("Profundidade média: ", round(depth_mean, 2)),
    vjust = 10,
    hjust = 0,
    color = "black",
    size = 5
  ) +
  coord_cartesian(xlim = c(0, 400)) +
  scale_x_continuous(breaks = seq(0, 400, by = 30)) +
  labs(
    title = "Histograma da Profundidade Média",
    x = "Profundidade média (X)",
    y = "Número de regiões"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_text(size = 12, face = "bold", margin = margin(r = 10)),
    axis.text.x = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold")
  )

# Salvar gráfico como imagem PNG
ggsave(
  filename = "/home/alexandre/wes_challenge_incor/results/histogram_covarage.png",
  plot = hist_graf,
  width = 10,
  height = 6
)

