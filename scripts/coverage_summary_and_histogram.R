#!/usr/bin/env Rscript

# =============================================================
# Script Name: coverage_summary_and_histogram.R
# Author: Alexandre J. Borges
# Description:
#   Performs exploratory analysis and histogram generation from
#   a BED file with coverage data.
#   Outputs:
#     - ../results/exploratory_analysis_coverage.csv
#     - ../results/histogram_coverage.png
# =============================================================

# Handle arguments
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  stop("Usage: Rscript coverage_summary_and_histogram.R <input_bed_file>")
}

input_file <- args[1]
output_csv <- "results/exploratory_analysis_coverage.csv"
output_png <- "results/histogram_coverage.png"

# Load or install required packages silently
required_packages <- c("ggplot2", "readr", "dplyr")

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "http://cran.us.r-project.org")
  }
  suppressPackageStartupMessages(library(pkg, character.only = TRUE))
}

cat("[INFO] Reading file:", input_file, "\n")

# Read input BED file
dataset <- read_tsv(
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

# --------- Part 1: Summary statistics ---------
cat("[INFO] Calculating coverage statistics...\n")

mean_depth    <- mean(dataset$depth, na.rm = TRUE)
min_depth     <- min(dataset$depth, na.rm = TRUE)
max_depth     <- max(dataset$depth, na.rm = TRUE)
coverage_10x  <- sum(dataset$depth >= 10) / nrow(dataset) * 100
coverage_30x  <- sum(dataset$depth >= 30) / nrow(dataset) * 100

summary_df <- data.frame(
  metric = c("Mean Depth", "Minimum Depth", "Maximum Depth",
             "Regions with Coverage ≥ 10x (%)",
             "Regions with Coverage ≥ 30x (%)"),
  value = c(mean_depth, min_depth, max_depth, coverage_10x, coverage_30x)
)

write.csv(summary_df, output_csv, row.names = FALSE)
cat("[INFO] Summary written to:", output_csv, "\n")

cat("========== Coverage Summary ==========\n")
print(summary_df)
cat("======================================\n")

# --------- Part 2: Histogram ---------
cat("[INFO] Generating histogram plot...\n")

filtered_data <- dataset %>%
  filter(depth > 0)

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

ggsave(
  filename = output_png,
  plot = hist_plot,
  width = 10,
  height = 6
)

cat("[INFO] Histogram saved to:", output_png, "\n")

