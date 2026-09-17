# Practical Machine Learning: Course Project

**Author:** Sonja Sahebzad

This repository contains the reproducible R Markdown analysis for the Johns Hopkins University / Coursera Practical Machine Learning prediction assignment. The objective is to predict how well participants performed a barbell lift from wearable-sensor measurements.

## View the report

- [Published HTML report](https://sonja242.github.io/practical-machine-learning-course-project/)
- [`Prediction_Assignment_Writeup_Sonja_Sahebzad.Rmd`](Prediction_Assignment_Writeup_Sonja_Sahebzad.Rmd): R Markdown source
- [`Prediction_Assignment_Writeup_Sonja_Sahebzad.html`](Prediction_Assignment_Writeup_Sonja_Sahebzad.html): compiled HTML report

## Files

- `Prediction_Assignment_Writeup_Sonja_Sahebzad.Rmd`: complete reproducible analysis and discussion.
- `Prediction_Assignment_Writeup_Sonja_Sahebzad.html`: compiled, self-contained report.
- `index.html`: GitHub Pages entry point for the published report.
- `pml_course_project_analysis.R`: preprocessing, cross-validation, model fitting, evaluation, and prediction script.
- `pml-training.csv`: official course training data.
- `pml-testing.csv`: 20 official course prediction cases.
- `quiz_predictions.csv`: all 20 predictions in order.
- `prediction_files/`: one prediction answer file for each test case.
- `analysis_results.rds`: saved analysis results used by the report.
- `Practical_Machine_Learning_Course_Project.Rproj`: RStudio project file.

## Model

The outcome is `classe`, with five exercise-execution classes (A to E). Identifiers, participant names, timestamps, and window bookkeeping fields are removed because they describe data collection rather than body movement. Predictors observed in fewer than 95% of rows are also removed, leaving 52 complete sensor predictors.

A fixed-seed stratified 75/25 split separates model development from final validation. Within the development set, five-fold stratified cross-validation compares a classification tree with a random forest. The random forest is selected because it performs substantially better while naturally modeling nonlinear relationships and interactions among sensor measurements.

- Mean five-fold cross-validation accuracy: **99.32%**
- Independent validation accuracy: **99.61%**
- Estimated independent validation error: **0.39%**

The report discusses the expected out-of-sample error, uncertainty, interaction handling, model comparison, and limitations of a row-level split.

## Expected quiz answers

`B A B A A E D B A A B C B A E E A B B B`

## Rendering

Open `Practical_Machine_Learning_Course_Project.Rproj` in RStudio. Run `pml_course_project_analysis.R` to reproduce the fitted models and saved results, then open `Prediction_Assignment_Writeup_Sonja_Sahebzad.Rmd` and click **Knit** to regenerate the HTML report.

The analysis uses `randomForest`, `rpart`, `knitr`, and `rmarkdown`. All file paths are relative to the project directory, so the repository can be moved, cloned, or downloaded without changing the code.

