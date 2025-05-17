#!/usr/bin/env Rscript
# Load the necessary library explicitly
library(ggplot2)
library(readr)
suppressPackageStartupMessages(library(dplyr))
library(stringr)


# ====== Parameters ======
# Get the sample name from the command line argument
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: R ./sex_inference_base.R <sample_name>")
}
sample_name <- args[1]

# Construct the input file path based on the repository structure
coverage_file <- file.path("results", paste0(sample_name, ".mosdepth.summary.txt"))

# Thresholds for sex inference
x_female_lower_threshold <- 0.8
x_male_upper_threshold <- 0.6
y_male_lower_threshold <- 0.1

# Output directory for results
output_dir <- "results"
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}
output_plot_file <- file.path(output_dir, paste0(sample_name, "_chrXY_coverage.png"))

# ====== Read the coverage file ======
df <- read.table(coverage_file, header = TRUE, sep = "\t", comment.char = "#", stringsAsFactors = FALSE)

# ====== Filter main chromosomes ======
df_filt <- df[grep("^chr[0-9XY]+$", df$chrom), ]

# Average coverage of autosomes
autosomes_df <- df_filt[grep("^chr[0-9]+$", df_filt$chrom), ]
mean_autosomes <- mean(autosomes_df$mean, na.rm = TRUE)

# Coverage on X and Y chromosomes
coverage_X <- df_filt[df_filt$chrom == "chrX", "mean"]
coverage_Y <- df_filt[df_filt$chrom == "chrY", "mean"]

# Normalized ratios
relative_X <- coverage_X / mean_autosomes
relative_Y <- coverage_Y / mean_autosomes

# Sex inference
if (relative_X >= x_female_lower_threshold && relative_Y < y_male_lower_threshold) {
  inferred_sex <- "Female (XX)"
} else if (relative_X <= x_male_upper_threshold && relative_Y >= y_male_lower_threshold) {
  inferred_sex <- "Male (XY)"
} else if (relative_X >= x_female_lower_threshold && relative_Y >= y_male_lower_threshold) {
  inferred_sex <- "Possible aneuploidy (e.g., XXY)"
} else if (relative_X <= x_male_upper_threshold && relative_Y < y_male_lower_threshold) {
  inferred_sex <- "Possible aneuploidy (e.g., X0)"
} else {
  inferred_sex <- "Indeterminate"
}

# Display results
cat("=== Genetic Sex Inference ===\n")
cat("Sample:", sample_name, "\n")
cat("Average autosome coverage:", round(mean_autosomes, 2), "\n")
cat("chrX coverage:", round(coverage_X, 2), "(", round(relative_X, 2), "x autosomes)\n")
cat("chrY coverage:", round(coverage_Y, 2), "(", round(relative_Y, 2), "x autosomes)\n")
cat("Inferred sex:", inferred_sex, "\n")

# Plotting with ggplot2 (without loading the entire tidyverse)
df_plot <- mutate(
  df_filt,
  tipo = case_when(
    str_detect(chrom, "^chr[0-9]+$") ~ "Autossomos",
    chrom == "chrX" ~ "X",
    chrom == "chrY" ~ "Y"
  ),
  chrom_clean = factor(str_remove(chrom, "^chr"), levels = c(as.character(1:22), "X", "Y")) # Ensure correct order
)

chr_cover_plot <- ggplot(df_plot, aes(x = chrom_clean, y = mean, fill = tipo)) +
  geom_col() +
  geom_text(
    data = df_plot %>% filter(chrom %in% c("chrX", "chrY")),
    aes(label = round(mean, 1), y = mean),
    vjust = -0.3,
    size = 4
  ) +
  geom_hline(yintercept = mean_autosomes, linetype = "dashed", color = "black") +
  annotate("text",
           x = which(levels(df_plot$chrom_clean) == "X"),
           y = mean_autosomes,
           label = paste("Média dos autossomos:", round(mean_autosomes, 2)),
           vjust = -0.5, hjust = 1.5, size = 4,
           color = "black", fontface = "bold") +
  theme_bw() +
  labs(
    title = NULL,
    x = "Cromossomo",
    y = "Cobertura Média"
  ) +
  scale_fill_manual(values = c("Autossomos" = "lightgrey", "X" = "steelblue", "Y" = "tomato")) +
  theme(
    legend.position = "bottom",
    axis.text.x = element_text(vjust = 0.5, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    legend.text = element_text(size = 12),
    legend.title = element_blank()
  )

ggsave(output_plot_file, chr_cover_plot, width = 10, height = 6)

cat("Plot saved to:", output_plot_file, "\n")
