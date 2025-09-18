# 📝 Future Improvements (TODO)

This is a list of potential improvements and tasks for this project.

### Repository Management
- [ ] **Implement `.gitignore`**: Create a `.gitignore` file to exclude generated files (`*.qza`, `*.qzv`) and output directories (`classifier/`, `test_output/`) from Git tracking. The goal is to only track source files.
- [ ] **Archive Past Versions**: Add classifier files from previous versions (e.g., from 2024) to the repository as official, version-tagged releases. A high priority is the classifier based on eHOMD RefSeq v15.23, as it was the version immediately preceding a major database update.
- [ ] **Explore GitHub Issues**: Consider using GitHub Issues for more detailed task management in the future.

### Documentation
- [ ] **Refine Citation Text**: Add the word "exclusively" to the citation instructions in the `README.md` to clarify that classifiers are only distributed via the Releases page.
- [ ] **Refine cloning instruction**: Add user instruction how to clone only specific subdirectories. 

### Classifier Validation
- [ ] **Run Cross-Validation**: Perform cross-validation analysis (`qiime feature-classifier evaluate-cross-validate`) on the trained classifiers to formally evaluate their performance.
- [ ] **Add Validation Results**: Add the cross-validation results (e.g., accuracy plots) to the `README.md` for each version to provide users with performance metrics.
