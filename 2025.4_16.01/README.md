## 🔧 Versions

- **QIIME2**: 2025.4  
- **eHOMD RefSeq**: Version 16.01 (released 2025/04/25)  
- **HOMD Taxonomy**: Version 4.0 (released 2025/04/25)

---

## 🔹 Objective

- Train a Naive Bayes classifier using **full-length** and **V3–V4 region** eHOMD 16S rRNA sequences.
- Compare classification performance between the full-length and region-specific classifiers.

---

## 🔍 Workflow Overview

1. **Start QIIME2 Environment**  
   - Instructions provided for both Docker and Conda environments.
   - Includes solution for locale error (`ValueError: unknown locale: UTF-8`).

2. **Download eHOMD Files**  
   - Includes FASTA sequences and taxonomy file formatted for QIIME2.

3. **Import Reference Files into QIIME2**  
   - Converts downloaded files into `.qza` artifacts.

4. **Train and Test Classifier (Full-Length)**  
   - Train using full-length sequences.
   - Classify representative sequences and visualize results.

5. **Train and Test Classifier (V3–V4 Region)**  
   - Extract V3–V4 region without length filters (to retain Fusobacterium).
   - Train and evaluate performance using extracted reads.

---

## 📊 Summary of Findings

- Classifier trained on **V3–V4 region** generally shows **higher confidence** in taxonomic assignments.
- However, for certain species (e.g., *Porphyromonas*), the **full-length classifier** offers better resolution.

---

## 📁 Example Commands (Excerpt)

```bash
# Train classifier with full-length sequences
qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads HOMD_16.01.qza \
  --i-reference-taxonomy HOMD_16.01-taxonomy.qza \
  --o-classifier classifier_HOMD-16.01_full.qza
```

```bash
# Extract V3–V4 region without length filter
qiime feature-classifier extract-reads \
  --p-f-primer CCTACGGGNGGCWGCAG \
  --p-r-primer GGGACTACHVGGGTWTCTAAT \
  --p-min-length 0 --p-max-length 0
```

---

## 📌 Notes

- Applying length filters when using V3-V4 led to underrepresentation of Fusobacterium species, so no lenght limit is applied.
- Make sure taxonomy file is in QIIME2-compatible format (`HeaderlessTSVTaxonomyFormat`).

---

## 📄 License

This project is licensed under the MIT License.
