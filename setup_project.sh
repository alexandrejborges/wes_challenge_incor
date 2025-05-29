#!/bin/bash
set -euo pipefail


# =============================================================
# Script Name: setup_project.sh
# Author: Alexandre J. Borges
# Description:
#   Sets up the WES project structure and Conda environments.
#   Creates required folders and environments for the pipeline.
#   Download the necessary scripts
# =============================================================



# Download script files
SCRIPT_REPO_URL="https://raw.githubusercontent.com/alexandrejborges/wes_challenge_incor/main/scripts"
SCRIPT_NAMES=(
    "contamination_verifybamid.sh"
    "convert_cram_to_bam.sh"
    "coverage_mosdepth.sh"
    "coverage_summary_and_histogram.R"
    "download_all.sh"
    "run_pipeline.sh"
    "sex_inference.R"
)
echo "Downloading scripts to ${PROJECT_DIR}/scripts..."
for script in "${SCRIPT_NAMES[@]}"; do
    curl -fsSL "${SCRIPT_REPO_URL}/${script}" -o "${PROJECT_DIR}/scripts/${script}"
    chmod +x "${PROJECT_DIR}/scripts/${script}"
    echo " → Downloaded: ${script}"
done
echo "All scripts downloaded."

# Creat directories
PROJECT_DIR="wes_challenge_incor"
echo "Creating project directory structure..."
mkdir -p "${PROJECT_DIR}"/{data,logs,results,scripts}
echo "Directory structure created under ${PROJECT_DIR}/"
tree -L 2 "${PROJECT_DIR}/"

# Create Conda environment: wes_qc_env
echo "Creating Conda environment: wes_qc_env..."
conda create -y -n wes_qc_env -c conda-forge -c bioconda \
    samtools=1.17 wget mosdepth \
    r-base=4.2.2 \
    r-ggplot2 r-dplyr r-stringr r-readr r-data.table

# Create Conda environment: verifybam_env
echo "Creating Conda environment: verifybam_env..."
conda create -y -n verifybam_env -c bioconda -c conda-forge verifybamid

echo "Conda environments created successfully."
echo "Tip: Activate with 'conda activate wes_qc_env' or 'conda activate verifybam_env'"
