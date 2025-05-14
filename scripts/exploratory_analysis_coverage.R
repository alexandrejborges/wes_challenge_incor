# =============================================================
# Script Name: exploratory_analysis_coverage.R
# Author: Alexandre J. Borges
# Last Modified: 2025-05-14
# Project: WES-QC: Whole Exome Sequencing Quality Control Pipeline
# Description:
#   This script conducts an exploratory analysis of sequencing coverage in
#   exonic regions. 
# =============================================================


# Input argument: input file path
args <- commandArgs(trailingOnly = TRUE)

if (length(args) != 1) {
  stop("Usage: Rscript exploratory_analysis_coverage.R <input_file>")
}

input_file <- args[1]
output_csv <- "../results/exploratory_analysis_coverage.csv"
log_file   <- "../logs/exploratory_analysis_coverage.log"

# Start logging
sink(log_file, split = TRUE)

# Load required library
library(readr)

cat("[INFO] Loading input file:", input_file, "\n")

# Read input dataset
dataset <- read_tsv(input_file,
                    col_names = c("chr", "start", "end", "sample", "depth"),
                    col_types = cols(
                      chr = col_character(),
                      start = col_integer(),
                      end = col_integer(),
                      sample = col_character(),
                      depth = col_double()))

# Compute coverage statistics
cat("[INFO] Calculating coverage statistics...\n")
mean_depth    <- mean(dataset$depth, na.rm = TRUE)
min_depth     <- min(dataset$depth, na.rm = TRUE)
max_depth     <- max(dataset$depth, na.rm = TRUE)
coverage_10x  <- sum(dataset$depth >= 10) / nrow(dataset) * 100
coverage_30x  <- sum(dataset$depth >= 30) / nrow(dataset) * 100

# Create summary data frame
summary_df <- data.frame(
  metric = c("Mean Depth", "Minimum Depth", "Maximum Depth",
             "Regions with Coverage ≥ 10x (%)",
             "Regions with Coverage ≥ 30x (%)"),
  value = c(mean_depth, min_depth, max_depth, coverage_10x, coverage_30x)
)

# Write summary to CSV
write.csv(summary_df, output_csv, row.names = FALSE)
cat("[INFO] Summary written to:", output_csv, "\n")

# Print summary to log
cat("========== Coverage Summary ==========\n")
print(summary_df)
cat("======================================\n")

# Stop logging
sink()
