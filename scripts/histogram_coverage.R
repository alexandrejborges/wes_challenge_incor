#!/usr/bin/env Rscript

# =============================================================
# Script Name: histogram_coverage.R
# Author: Alexandre J. Borges
# Last Modified: 2025-05-14
# Description:
#   This script reads a BED file with coverage information,
#   filters non-zero coverage regions, computes the mean depth,
#   and generates a histogram saved as a PNG image.
#   Output files:
#     - ../results/histogram_coverage.png
#     - ../logs/exploratory_coverage_histogram.log
# =============================================================

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  stop("Usage: Rscript exploratory_coverage_histogram.R <input_bed_file>")
}

input_file <- args[1]
output_png <- "../results/histogram_coverage.png"
log_file   <- "../logs/histogram_coverage.log"

# Start logging
sink(log_file, split = TRUE)

# Load or install required packages
required_packages <- c("ggplot2", "readr", "dplyr")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

cat("[INFO] Reading file:", input_file, "\n")

# Load dataset
data <- read_tsv(
  input_file,
  col_names = c("chr", "start", "end", "sample", "depth"),
  col_types = cols(
    chr = col_character(),
    start = col_integer(),
    end = col_integer(),
    sample = col_character(),
    depth = col_double()
  )
)

# Filter out zero-depth regions
filtered_data <- data %>%
  filter(depth > 0)

# Compute mean depth
mean_depth <- mean(data$depth, na.rm = TRUE)

# Create histogram
hist_plot <- ggplot(filtered_data, aes(x = depth)) +
  geom_histogram(binwidth = 10, fill = "steelblue", color = "black") +
  geom_vline(xintercept = mean_depth, color = "black", linetype = "dashed", size = 1) +
  annotate(
    "text",
    x = mean_depth + 10,
    y = Inf,
    label = paste0("Mean depth: ", round(mean_depth, 2), "x"),
    vjust = 10,
    hjust = 0,
    color = "black",
    size = 5
  ) +
  coord_cartesian(xlim = c(0, 400)) +
  scale_x_continuous(breaks = seq(0, 400, by = 30)) +
  labs(
    title = "Histogram of Mean Coverage Depth",
    x = "Coverage Depth (X)",
    y = "Number of Regions"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
    axis.title.y = element_text(size = 12, face = "bold", margin = margin(r = 10)),
    axis.text.x = element_text(size = 12, face = "bold"),
    axis.text.y = element_text(size = 12, face = "bold")
  )

# Save PNG
ggsave(
  filename = output_png,
  plot = hist_plot,
  width = 10,
  height = 6
)
cat("[INFO] Histogram saved to:", output_png, "\n")
cat("[INFO] Log saved to:", log_file, "\n")

# Stop logging
sink()
