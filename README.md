# Practical Machine Learning Course Project

This repository contains Sonja Sahebzad's reproducible prediction assignment.

- `Prediction_Assignment_Writeup_Sonja_Sahebzad.Rmd`: source report
- `Prediction_Assignment_Writeup_Sonja_Sahebzad.html`: compiled, self-contained report
- `pml_course_project_analysis.R`: complete preprocessing, cross-validation, fitting, and prediction script
- `quiz_predictions.csv`: predictions for the 20 course test cases
- `prediction_files/`: one answer file per test case
- `pml-training.csv` and `pml-testing.csv`: unchanged course data

Run `pml_course_project_analysis.R` from R, then knit the R Markdown file. The script locates the data relative to itself, so the repository can be moved or downloaded. The analysis requires `randomForest`, `rpart`, `knitr`, and `rmarkdown`.
