# training feature classifier

## QIIME2 version: 2025.4
## eHOMD Refseq version: 16.01 (released on 2025/4/25)
## HOMD taxonomy version: V4.0 (released on 2025/4/25) 

## download files from HOMD
### download "eHOMD 16S rRNA Refseq Version 16.01" (HOMD_16S_rRNA_RefSeq_V16.01_full.fasta)
### download "eHOMD 16S rRNA Refseq Version 16.01 Taxonomy file for QIIME" (HOMD_16S_rRNA_RefSeq_V16.01.qiime.taxonomy)

## note (2025/6/1)
## Error occurred when making a barplot with the classifier as below, probably due to the empty taxonomy in the file downloaded from HOMD.
## the command below is used to replace rows with empty taxonomy and fill it with "k__Bacteria" .
## this could be needed only temporarily until the HOMD taxonomy is updated.
awk -F '\t' 'BEGIN{OFS="\t"} {if ($2 == "") $2 = "k__Bacteria"; print}' \
  HOMD_download/HOMD_16S_rRNA_RefSeq_V16.01.qiime.taxonomy > HOMD_download/HOMD_16S_rRNA_RefSeq_V16.01.qiime.taxonomy_filled

## start QIIME2
### when using Docker 
docker run --rm -it -v "$(pwd):/data" quay.io/qiime2/amplicon:2025.4

### when using conda
conda activate qiime2-2025.5

#### When 'ValueError: unknown locale: UTF-8' error occurs.
export LC_ALL=ja_JP.UTF-8

## import --- Use unaliged fastq file to import --
### eHOMD 16S rRNA RefSeq Version 16.01 (full)
qiime tools import \
  --type 'FeatureData[Sequence]' \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.01.fasta \
  --output-path HOMD_16.01.qza

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-format HeaderlessTSVTaxonomyFormat \
  --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.01.qiime.taxonomy_filled \
  --output-path HOMD_16.01-taxonomy.qza

## training 
### using full length HOMD 16S refseqs 
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.01_full.qza \
  --i-reference-taxonomy HOMD_16.01-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.01_full.qza

## test the classifier
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.01_full.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_full.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_full.qza \
  --o-visualization test_output/taxonomy_full.qzv

## training a classifier using sequence between V3-V4
# original primers (used in 16S PCR for Miseq sequencing)
#  --p-f-primer TCGTCGGCAGCGTCAGATGTGTATAAGAGACAGCCTACGGGNGGCWGCAG \
#  --p-r-primer GTCTCGTGGGCTCGGAGATGTGTATAAGAGACAGGGACTACHVGGGTWTCTAAT \

## 'biological sequnece' was determined using BLASTN suite 16S rRNA database with latter half of the above original primer sequences
## extract reads
### with no length limit (when --p-min-length and --p-max length were set, Fusobacterium was underrepresented)
qiime feature-classifier extract-reads \
 --i-sequences HOMD_16.01_full.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGGACTACHVGGGTWTCTAAT \
  --p-min-length 0 \
  --p-max-length 0 \
  --o-reads HOMD_16.01_V3-V4.qza

## training using V3-V4 region of eHOMD 16S 
### with no length limit
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.01_V3-V4.qza \
  --i-reference-taxonomy HOMD_16.01-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.01_V3-V4.qza

## test the clissifier
### with no length limit
### the result is comparable or better? compared to full length.
qiime feature-classifier classify-sklearn \
  --i-classifier classifier/classifier_HOMD-16.01_V3-V4.qza \
  --i-reads test_data/rep-seqs.qza \
  --o-classification test_output/taxonomy_V3-V4.qza

qiime metadata tabulate \
  --m-input-file test_output/taxonomy_V3-V4.qza \
  --o-visualization test_output/taxonomy_V3-V4.qzv

## note
## Classifier made with V3-V4 region gives higher confidence level than full length in general.
## However, some Porphyromonas species were classified with higher confidence level with full length classifier.
