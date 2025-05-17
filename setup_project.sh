#!/bin/bash
set -e

# =============================================================
# Script Name: setup_project.sh
# Author: Alexandre J. Borges
# Last Modified: 2025-05-17
# Description:
#   Sets up the WES project structure and Conda environments.
#   Creates required folders and environments for the pipeline.
# =============================================================

# Project directory
PROJECT_DIR="wes_challenge_incor"

echo "Creating project directory structure..."
mkdir -p ${PROJECT_DIR}/{data,logs,results,scripts,NON-automatizated}

echo "Directory structure created under ${PROJECT_DIR}/"
tree -L 2 ${PROJECT_DIR}/

# Create Conda environments
echo "Creating Conda environment: wes_qc_env..."
conda create -y -n wes_qc_env -c bioconda -c conda-forge \
    samtools wget md5sum coreutils r-base r-ggplot2 r-dplyr r-stringr r-readr

echo "Creating Conda environment: verifybam_env..."
conda create -y -n verifybam_env -c bioconda -c conda-forge verifybamid

echo "Conda environments created."

echo "Tip: Activate with 'conda activate wes_qc_env' or 'conda activate verifybam_env'"

