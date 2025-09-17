# QIIME 2 Classifiers for the expanded Human Oral Microbiome Database (eHOMD)

This repository provides pre-trained QIIME 2 feature classifiers based on the [expanded Human Oral Microbiome Database (eHOMD)](http://www.homd.org/). These classifiers are designed to improve the taxonomic resolution of 16S rRNA gene amplicon sequences from human oral samples compared to general-purpose databases like SILVA or Greengenes.

## Overview 📖

Standard taxonomic databases are broad but may lack the specificity needed for detailed analysis of the human oral microbiome. By using the curated and specialized eHOMD reference sequences, these classifiers can provide more accurate and detailed taxonomic assignments for oral bacteria.

This project offers transparency and reproducibility by including all scripts and source files used to generate each classifier.

## Versioning Scheme 🏷️

The version tags and directory names for the classifiers follow the format `v[QIIME2-version]-[eHOMD-version]`.

* **`[QIIME2-version]`**: Indicates the version of QIIME 2 the classifier was built with. Classifiers are generally only compatible with the QIIME 2 version they were trained on.
* **`[eHOMD-version]`**: Indicates the version of the eHOMD reference sequence database used.

For example, a classifier named `v2025.7-16.03` was created using QIIME 2 `2025.7` and eHOMD version `16.03`. This scheme is used to ensure maximum clarity and reproducibility for your analysis.

## Available Classifiers ✨

This repository provides two types of pre-trained classifiers. **Detailed usage, technical specifications, and build instructions are located in the README file within each directory.**

* ### [eHOMD Full-Length 16S rRNA Classifier]
    * **Description**: Trained on the full-length 16S rRNA gene sequences from the eHOMD. For sequence data amplified from regions other than V3-V4, this classifier can be used directly. Alternatively, advanced users can adapt the included scripts to build a custom classifier for their specific region of interest.
    
* ### [eHOMD V3-V4 Region 16S rRNA Classifier]
    * **Description**: Specifically trained on the V3-V4 hypervariable region of the 16S rRNA gene. Best for short-read sequencing data from the V3-V4 region (e.g., from Illumina platforms).

## How to Use 🚀

There are two ways to get the classifier files:

**Option 1: Simple Download (Recommended)**

If you only need the pre-trained classifier file (`.qza`), download it directly from the **[Releases Page](https://github.com/hmaru/qiime2_HOMD_classifier/releases)**. This ensures you get a stable, versioned file.

**Option 2: Full Repository Clone (Advanced)**

If you want to inspect the build scripts or reproduce the classifier yourself, clone the entire repository:
```bash
git clone [https://github.com/hmaru/qiime2_HOMD_classifier.git](https://github.com/hmaru/qiime2_HOMD_classifier.git)
cd qiime2_HOMD_classifier
```
## Prerequisites 🔧

* **QIIME 2**: This classifier was built using QIIME 2. We recommend using a version of the `qiime2/amplicon` distribution released in 2025 or later.

## Citation ✍️

To ensure reproducibility, please download the classifier from the **[Releases Page](https://github.com/hmaru/qiime2_HOMD_classifier/releases)** and cite the specific version you used in your analysis.

In addition to citing the specific release, we kindly ask you to also cite the original publications for eHOMD and QIIME 2.

* **This Repository (Example for version v1.0.0)**:
    `Maruyama H`. (2025). *qiime2_HOMD_classifier: QIIME 2 Classifiers for the eHOMD (Version v1.0.0)* [Computer software]. GitHub. https://github.com/hmaru/qiime2_HOMD_classifier/releases/tag/v1.0.0

* **eHOMD**: Fernández-Escapa I, Chen T, Huang Y, Gajare P, Dewhirst FE, Lemon KP. (2018). New insights into the human nostril microbiome from the expanded Human Oral Microbiome Database (eHOMD): a resource for species-level identification of microbiome data from the aerodigestive tract. mSystems 3:e00187-18. https://doi.org/10.1128/mSystems.00187-18.

* **QIIME 2**: Bolyen E, et al. (2019). Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. *Nat Biotechnol*, 37(8):852-857. doi:10.1038/s41587-019-0209-9.

## License 📄

This project is licensed under the [MIT License](LICENSE).
