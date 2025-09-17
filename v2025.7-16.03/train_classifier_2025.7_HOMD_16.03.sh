# Script to train a QIIME2 feature classifier using the HOMD database

## =============================================================================
## METADATA
## =============================================================================
## QIIME2 Version: 2025.7
## eHOMD RefSeq Version: 16.03 (released on 2025/08/25)
## HOMD Taxonomy Version: V4.1 (released on 2025/08/25) 

## =============================================================================
## SETUP
## =============================================================================

# 1. Download required files from the HOMD website
# -----------------------------------------------------------------------------
### Download "eHOMD 16S rRNA Refseq Version 16.03" -> HOMD_16S_rRNA_RefSeq_V16.03_full.fasta
### Download "eHOMD 16S rRNA Refseq Version 16.03 Taxonomy file for QIIME" -> HOMD_16S_rRNA_RefSeq_V16.03.qiime.taxonomy

# 2. Activate QIIME2 environment
# -----------------------------------------------------------------------------
### Using Docker
docker run --rm -it -v "$(pwd):/data" quay.io/qiime2/amplicon:2025.7

### Using Conda
# conda activate qiime2-2025.7

#### Note: If you encounter a 'ValueError: unknown locale: UTF-8' error, run the following command:
# export LC_ALL=en_US.UTF-8 # Or your preferred locale, e.g., ja_JP.UTF-8

# 3. Import data into QIIME2 artifacts
# -----------------------------------------------------------------------------
### Import reference sequences (full-length)
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03_full.fasta \
  --output-path HOMD_16.03_full.qza

### Import taxonomy file
qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03.qiime.taxonomy \
  --output-path HOMD_16.03-taxonomy.qza

## =============================================================================
## OPTION 1: Train classifier using FULL-LENGTH reference sequences
## =============================================================================

# 1. Train the Naive Bayes classifier
# -----------------------------------------------------------------------------
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_full.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_full.qza

# 2. Test the full-length classifier
# -----------------------------------------------------------------------------
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.03_full.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_full.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_full.qza \
  --o-visualization test_output/taxonomy_full.qzv

## =============================================================================
## OPTION 2: Train classifier using the V3-V4 REGION
## =============================================================================

# 1. Extract the V3-V4 region from reference sequences
# -----------------------------------------------------------------------------
### These are the full-length primers used for the initial 16S PCR amplification for MiSeq library preparation.
###  --p-f-primer TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG
###  --p-r-primer GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGGACTACHVGGGTWTCTAAT

### The biological primer sequences below were identified by running a BLASTN search
### against a 16S rRNA database using the 3' half of the full-length primers shown above.
###
### NOTE: Length filtering is disabled (`--p-min-length 0` and `--p-max-length 0`) because applying
### a specific length range was found to cause underrepresentation of *Fusobacterium* species
### in the resulting classifier. (Comparative data for this finding is not included here).
qiime feature-classifier extract-reads \
  --i-sequences HOMD_16.03_full.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGGACTACHVGGGTWTCTAAT \
  --p-min-length 0 \
  --p-max-length 0 \
  --o-reads HOMD_16.03_V3-V4.qza

# 2. Train the classifier on the extracted V3-V4 reads
# -----------------------------------------------------------------------------
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_V3-V4.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_V3-V4.qza

# 3. Test the V3-V4 classifier
# -----------------------------------------------------------------------------
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.03_V3-V4.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_V3-V4.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_V3-V4.qza \
  --o-visualization test_output/taxonomy_V3-V4.qzv

## =============================================================================
## VALIDATION STEP: Test classifier functionality with bar plots
## =============================================================================
## NOTE (Historical Context):
## Previous versions of the HOMD taxonomy file (e.g., v16.01, around 2025/06/01)
## contained empty taxonomy strings for some entries. This did not cause an
## error during classifier training, but it did cause the `qiime taxa barplot`
## command to fail.
##
## The error message was as follows:
###  File "/opt/conda/envs/qiime2-amplicon-2025.7/lib/python3.10/site-packages/q2_taxa/_util.py", line 11, in <lambda>
###    return taxonomy.apply(lambda x: len(x.split(';'))).max()
### AttributeError: 'float' object has no attribute 'split'
##
## The commands below serve as a validation check to ensure this issue has been
## resolved in the current HOMD version (v16.03). If these commands execute
## successfully, it confirms the classifier and taxonomy file are well-formed.
## =============================================================================

# 1. Test the FULL-LENGTH classifier
# -----------------------------------------------------------------------------
qiime taxa barplot \
  --i-table test_data/table.qza \
  --i-taxonomy test_output/taxonomy_full.qza \
  --o-visualization test_output/barplot_full.qzv \

# 2. Test the V3-V4 classifier
# -----------------------------------------------------------------------------
qiime taxa barplot \
  --i-table test_data/table.qza \
  --i-taxonomy test_output/taxonomy_V3-V4.qza \
  --o-visualization test_output/barplot_V3-V4.qzv \

## =============================================================================
## NOTES
## =============================================================================
## - The classifier trained on the V3-V4 region generally yields slightly higher
##   classification confidence than the full-length classifier.
##
## - However, for certain taxa, such as some *Porphyromonas* species, the
##   full-length classifier may provide higher confidence classifications.
##
## - As mentioned above, length filtering is disabled during V3-V4 extraction to
##   prevent the underrepresentation of *Fusobacterium* species. This behavior
##   may require further investigation.