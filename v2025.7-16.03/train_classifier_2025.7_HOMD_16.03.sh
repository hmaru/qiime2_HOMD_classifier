#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Script to train and validate QIIME2 feature classifiers using the eHOMD database

# =============================================================================
# METADATA
# =============================================================================
# QIIME2 Version: 2025.7
# eHOMD RefSeq Version: 16.03 (released on 2025/08/25)
# HOMD Taxonomy Version: V4.1 (released on 2025/08/25) 

# =============================================================================
# SETUP: Prepare Environment and Data
# =============================================================================

# Step 1: Download required files from the HOMD website
# -----------------------------------------------------------------------------
# PURPOSE: Obtain the latest reference sequences and taxonomy files.
# ACTIONS:
#   - Download "eHOMD 16S rRNA Refseq Version 16.03" -> e.g., HOMD_16S_rRNA_RefSeq_V16.03_full.fasta
#   - Download "eHOMD 16S rRNA Refseq Version 16.03 Taxonomy file for QIIME" -> e.g., HOMD_16S_rRNA_RefSeq_V16.03.qiime.taxonomy

# Step 2: Activate QIIME2 environment
# -----------------------------------------------------------------------------
# PURPOSE: Load the necessary QIIME2 software environment.
# NOTE: Choose the appropriate command for your setup (Docker or Conda).
#
# Using Docker:
# docker run --rm -it -v "$(pwd):/data" quay.io/qiime2/amplicon:2025.7
#
# Using Conda:
# conda activate qiime2-amplicon-2025.7

# If you encounter a 'ValueError: unknown locale: UTF-8', run this before starting QIIME2:
# export LC_ALL=en_US.UTF-8

# Step 3: Import data into QIIME2 artifacts
# -----------------------------------------------------------------------------
# PURPOSE: Convert the raw text files (.fasta, .taxonomy) into QIIME2's native format (.qza).
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03_full.fasta \
  --output-path HOMD_16.03_full.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03.qiime.taxonomy \
  --output-path HOMD_16.03-taxonomy.qza

# =============================================================================
# WORKFLOW 1: Train and Test FULL-LENGTH Classifier
# =============================================================================

# Step 1.1: Train the Naive Bayes classifier
# -----------------------------------------------------------------------------
# PURPOSE: Build the classifier using the complete, full-length 16S reference sequences.
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_full.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_full.qza

# Step 1.2: Test the classifier
# -----------------------------------------------------------------------------
# PURPOSE: Use the trained classifier to assign taxonomy to a set of test sequences.
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.03_full.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_full.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_full.qza \
  --o-visualization test_output/taxonomy_full.qzv

# =============================================================================
# WORKFLOW 2: Train and Test V3-V4 REGION Classifier
# =============================================================================

# Step 2.1: Extract the V3-V4 region from reference sequences
# -----------------------------------------------------------------------------
# PURPOSE: Simulate PCR amplification of the V3-V4 region to create a region-specific reference.

### These are the full-length primers used for the initial 16S PCR amplification for MiSeq library preparation.
###  --p-f-primer TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG
###  --p-r-primer GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGGACTACHVGGGTWTCTAAT

### The biological primer sequences below were identified by running a BLASTN search
### against a 16S rRNA database using the 3' half of the full-length primers shown above.
###
# NOTE: Length filtering is disabled (--p-min-length 0, --p-max-length 0) because applying
# a specific length range was found to cause underrepresentation of *Fusobacterium* species
# in the resulting classifier.
qiime feature-classifier extract-reads \
  --i-sequences HOMD_16.03_full.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGGACTACHVGGGTWTCTAAT \
  --p-min-length 0 \
  --p-max-length 0 \
  --o-reads HOMD_16.03_V3-V4.qza

# Step 2.2: Train the classifier on the extracted V3-V4 reads
# -----------------------------------------------------------------------------
# PURPOSE: Build the classifier using only the V3-V4 reference sequences.
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_V3-V4.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_V3-V4.qza

# Step 2.3: Test the V3-V4 classifier
# -----------------------------------------------------------------------------
# PURPOSE: Use the V3-V4 classifier to assign taxonomy to the test sequences.
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.03_V3-V4.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_V3-V4.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_V3-V4.qza \
  --o-visualization test_output/taxonomy_V3-V4.qzv

# =============================================================================
# VALIDATION: Ensure Bar Plots Can Be Generated
# =============================================================================
# PURPOSE: This step serves as a sanity check. Previous versions of the HOMD
# taxonomy file had formatting issues that caused `qiime taxa barplot` to fail.
# Successful execution of these commands confirms the current taxonomy file is
# correctly formatted and the classifier is compatible with downstream visualization.
# -----------------------------------------------------------------------------
qiime taxa barplot \
  --i-table test_data/table.qza \
  --i-taxonomy test_output/taxonomy_full.qza \
  --o-visualization test_output/barplot_full.qzv

qiime taxa barplot \
  --i-table test_data/table.qza \
  --i-taxonomy test_output/taxonomy_V3-V4.qza \
  --o-visualization test_output/barplot_V3-V4.qzv

echo "Script finished successfully."