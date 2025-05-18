#!/usr/bin/env Rscript

# =============================================================
# Script Name: sex_inference.R
# Author: Alexandre J. Borges
# Description:
#   Performs genetic sex inference based on chrX and chrY coverage
#   from a mosdepth summary file.
#   Input:
#     - results/<sample>.mosdepth.summary.txt
#   Output:
#     - results/<sample>_chrXY_coverage.png
# =============================================================

# Load required libraries
suppressPackageStartupMessages({
  library(ggplot2)
  library(readr)
  library(dplyr)
  library(stringr)
})

# Get sample name
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) {
  stop("Usage: Rscript sex_inference.R <sample_name>")
}
sample_name <- args[1]

# Paths
input_file <- file.path("results", paste0(sample_name, ".mosdepth.summary.txt"))
output_plot <- file.path("results", paste0(sample_name, "_chrXY_coverage.png"))

# Read data
cat("[INFO] Reading coverage file:", input_file, "\n")
df <- read.table(input_file, header = TRUE, sep = "\t", comment.char = "#", stringsAsFactors = FALSE)

# Filter chrX, chrY, and autosomes
df_filt <- df[grep("^chr[0-9XY]+$", df$chrom), ]
autosomes_df <- df_filt[grep("^chr[0-9]+$", df_filt$chrom), ]
mean_autosomes <- mean(autosomes_df$mean, na.rm = TRUE)

coverage_X <- df_filt[df_filt$chrom == "chrX", "mean"]
coverage_Y <- df_filt[df_filt$chrom == "chrY", "mean"]

relative_X <- coverage_X / mean_autosomes
relative_Y <- coverage_Y / mean_autosomes

# Inference thresholds
x_female_lower_threshold <- 0.8
x_male_upper_threshold <- 0.6
y_male_lower_threshold <- 0.1

# Inference logic
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

# Report
cat("=== Genetic Sex Inference ===\n")
cat("Sample:", sample_name, "\n")
cat("Average autosome coverage:", round(mean_autosomes, 2), "\n")
cat("chrX coverage:", round(coverage_X, 2), "(", round(relative_X, 2), "x autosomes)\n")
cat("chrY coverage:", round(coverage_Y, 2), "(", round(relative_Y, 2), "x autosomes)\n")
cat("Inferred sex:", inferred_sex, "\n")

# Save inference summary to TXT
output_txt <- file.path("results", paste0(sample_name, "_sex_inference.txt"))
writeLines(c(
  "=== Genetic Sex Inference ===",
  paste("Sample:", sample_name),
  paste("Average autosome coverage:", round(mean_autosomes, 2)),
  paste("chrX coverage:", round(coverage_X, 2), "(", round(relative_X, 2), "x autosomes)"),
  paste("chrY coverage:", round(coverage_Y, 2), "(", round(relative_Y, 2), "x autosomes)"),
  paste("Inferred sex:", inferred_sex)
), con = output_txt)


# Plotting
df_plot <- mutate(
  df_filt,
  tipo = case_when(
    str_detect(chrom, "^chr[0-9]+$") ~ "Autosome",
    chrom == "chrX" ~ "X",
    chrom == "chrY" ~ "Y"
  ),
  chrom_clean = factor(str_remove(chrom, "^chr"), levels = c(as.character(1:22), "X", "Y"))
)

chr_cover_plot <- ggplot(df_plot, aes(x = chrom_clean, y = mean, fill = tipo)) +
  geom_col() +
  geom_text(
    data = df_plot %>% filter(chrom %in% c("chrX", "chrY")),
    aes(label = round(mean, 1), y = mean),
    vjust = -0.3,
    size = 4
  ) +
  geom_hline(yintercept = mean_autosomes, linetype = "dashed", color = "black", linewidth = 1) +
  annotate("text",
           x = which(levels(df_plot$chrom_clean) == "X"),
           y = mean_autosomes,
           label = paste("Autosome mean:", round(mean_autosomes, 2)),
           vjust = -0.5, hjust = 1.5, size = 4,
           color = "black", fontface = "bold") +
  theme_bw() +
  labs(
    title = NULL,
    x = "Chromosome",
    y = "Mean depth"
  ) +
  scale_fill_manual(values = c("Autosome" = "lightgrey", "X" = "steelblue", "Y" = "tomato")) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(vjust = 0.5, hjust = 1, size = 12),
    axis.text.y = element_text(size = 12),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12)
  )

ggsave(output_plot, chr_cover_plot, width = 10, height = 6)
cat("Plot saved to:", output_plot, "\n")

