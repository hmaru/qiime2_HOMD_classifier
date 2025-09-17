# 🧬 eHOMD Classifiers (v2025.7-16.03)

This directory contains the source files and documentation for the classifiers built with **QIIME 2 version `2025.7`** and **eHOMD database version `16.03`**.

For general project information, please see the [top-level README](../../README.md).

The complete, commented workflow is available in the script [`train_classifier_2025.7_HOMD_16.03.sh`](./train_classifier_2025.7_HOMD_16.03.sh). This README serves as a summary and guide.

## 🔧 Technical Specifications

- **QIIME 2 Version**: `2025.7`
- **eHOMD RefSeq Version**: `16.03` (released 2025/08/25)
- **HOMD Taxonomy Version**: `4.1` (released 2025/08/25)

## 🚀 How to Use the Pre-Trained Classifiers

The final, pre-trained classifier files (`.qza`) for this version are available for download on the project's **[Releases Page](https://github.com/hmaru/qiime2_HOMD_classifier/releases)**.

**Example command:**
```bash
qiime feature-classifier classify-sklearn \
  --i-classifier path/to/your/downloaded/classifier_HOMD-16.03_V3-V4.qza \
  --i-reads your-rep-seqs.qza \
  --o-classification taxonomy.qza
```

## 🔬 How to Rebuild the Classifiers

This section provides a step-by-step guide for users who wish to execute the build process manually.

### **Setup**

1.  **Download Source Files**: From the [eHOMD website](http://www.homd.org/), download the "eHOMD 16S rRNA Refseq Version 16.03" FASTA file and the corresponding "Taxonomy file for QIIME".
2.  **Activate QIIME 2**: Activate your `qiime2-2025.7` environment (either Conda or Docker).
3.  **Import to QIIME 2**: Convert the downloaded files into QIIME 2 artifacts (`.qza`).
    ```bash
    # Import reference sequences
    qiime tools import \
      --type 'FeatureData[Sequence]' \
      --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03_full.fasta \
      --output-path HOMD_16.03_full.qza

    # Import taxonomy
    qiime tools import \
      --type 'FeatureData[Taxonomy]' \
      --input-format HeaderlessTSVTaxonomyFormat \
      --input-path HOMD_download/HOMD_16S_rRNA_RefSeq_V16.03.qiime.taxonomy \
      --output-path HOMD_16.03-taxonomy.qza
    ```

### **Workflow 1: Full-Length Classifier**

Train the classifier using the complete, full-length 16S reference sequences.
```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_full.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_full.qza
```

### **Workflow 2: V3-V4 Region Classifier**
1. Extract V3-V4 Reads: Simulate PCR amplification to create a region-specific reference.

```bash
qiime feature-classifier extract-reads \
  --i-sequences HOMD_16.03_full.qza \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGGACTACHVGGGTWTCTAAT \
  --p-min-length 0 \
  --p-max-length 0 \
  --o-reads HOMD_16.03_V3-V4.qza
```
**Note on Length Filtering**: Length filters are intentionally disabled (`--p-min-length 0`, `--p-max-length 0`) to prevent the underrepresentation of Fusobacterium species, which can have amplicons outside the typical length range.

2. Train V3-V4 Classifier: Build the classifier using only the extracted V3-V4 sequences.

```bash
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.03_V3-V4.qza \
  --i-reference-taxonomy HOMD_16.03-taxonomy.qza \
  --o-classifier classifier/classifier_HOMD-16.03_V3-V4.qza
```

## 📊 Key Findings & Conclusion

- The classifier trained on the **V3-V4 region generally shows higher confidence** in taxonomic assignments for V3-V4 amplicon data.
- However, for certain species (e.g., within *Porphyromonas*), the **full-length classifier can offer better resolution**.

**Recommendation**: For typical V3-V4 studies, the V3-V4 specific classifier is recommended. If resolving specific taxa is a priority, comparing results with the full-length classifier may be beneficial.

---

## ✅ Validation Note

The build script includes a final `qiime taxa barplot` step. This is not for analysis, but serves as a crucial sanity check to ensure the HOMD taxonomy file is correctly formatted, as historical versions had issues that would cause this visualization command to fail.

## 📁 File Manifest

* `README.md`: This file, containing a summary and tutorial for this version (v2025.7-16.03).
* `train_classifier_2025.7_HOMD_16.03.sh`: An executable script containing all the commands to rebuild the classifiers from scratch.
* `HOMD_download/`: Directory containing the source files downloaded from the official eHOMD website.
* `test_data/`: Directory containing a small dataset to test the trained classifiers.
    * `rep-seqs.qza`: Representative sequences for testing.
    * `table.qza`: A feature table for testing `qiime taxa barplot`.