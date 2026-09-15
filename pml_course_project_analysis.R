set.seed(20260915)

suppressPackageStartupMessages({
  library(randomForest)
  library(rpart)
})

full_args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", full_args, value = TRUE)
data_dir <- if (length(file_arg)) {
  dirname(normalizePath(sub("^--file=", "", file_arg[1]), winslash = "/"))
} else {
  normalizePath(getwd(), winslash = "/")
}
train_raw <- read.csv(file.path(data_dir, "pml-training.csv"), na.strings = c("NA", "#DIV/0!", ""), check.names = FALSE)
test_raw  <- read.csv(file.path(data_dir, "pml-testing.csv"),  na.strings = c("NA", "#DIV/0!", ""), check.names = FALSE)

# Remove identifiers/time-window fields and variables unavailable for most rows.
metadata <- c("X", "user_name", "raw_timestamp_part_1", "raw_timestamp_part_2",
              "cvtd_timestamp", "new_window", "num_window")
candidate <- setdiff(names(train_raw), c(metadata, "classe"))
candidate <- candidate[nzchar(candidate)]
complete_share <- vapply(train_raw[candidate], function(x) mean(!is.na(x)), numeric(1))
predictors <- candidate[complete_share >= 0.95]

dat <- train_raw[c(predictors, "classe")]
dat$classe <- factor(dat$classe)

# Stratified 75/25 split, preserving each class proportion.
idx <- unlist(lapply(split(seq_len(nrow(dat)), dat$classe), function(i) {
  sample(i, floor(0.75 * length(i)))
}), use.names = FALSE)
development <- dat[idx, ]
validation <- dat[-idx, ]

# Five stratified folds within the development sample.
fold_id <- integer(nrow(development))
for (lev in levels(development$classe)) {
  rows <- which(development$classe == lev)
  fold_id[rows] <- sample(rep(1:5, length.out = length(rows)))
}

cv_rf <- numeric(5)
cv_tree <- numeric(5)
for (k in 1:5) {
  fit_rf <- randomForest(classe ~ ., data = development[fold_id != k, ],
                         ntree = 250, mtry = floor(sqrt(length(predictors))))
  pred_rf <- predict(fit_rf, development[fold_id == k, ])
  cv_rf[k] <- mean(pred_rf == development$classe[fold_id == k])

  fit_tree <- rpart(classe ~ ., data = development[fold_id != k, ], method = "class",
                    control = rpart.control(cp = 0.01, xval = 10))
  pred_tree <- predict(fit_tree, development[fold_id == k, ], type = "class")
  cv_tree[k] <- mean(pred_tree == development$classe[fold_id == k])
}

# Independent validation comparison.
rf_dev <- randomForest(classe ~ ., data = development, ntree = 500,
                       mtry = floor(sqrt(length(predictors))), importance = TRUE)
tree_dev <- rpart(classe ~ ., data = development, method = "class",
                  control = rpart.control(cp = 0.01, xval = 10))
rf_val_pred <- predict(rf_dev, validation)
tree_val_pred <- predict(tree_dev, validation, type = "class")
rf_cm <- table(Observed = validation$classe, Predicted = rf_val_pred)
tree_cm <- table(Observed = validation$classe, Predicted = tree_val_pred)
rf_acc <- sum(diag(rf_cm)) / sum(rf_cm)
tree_acc <- sum(diag(tree_cm)) / sum(tree_cm)

# Wilson interval for validation accuracy and corresponding error interval.
wilson <- function(x, n, z = qnorm(0.975)) {
  p <- x / n
  den <- 1 + z^2 / n
  centre <- (p + z^2 / (2*n)) / den
  half <- z * sqrt(p * (1-p) / n + z^2 / (4*n^2)) / den
  c(lower = centre - half, upper = centre + half)
}
acc_ci <- wilson(sum(diag(rf_cm)), sum(rf_cm))
error_ci <- rev(1 - acc_ci)

# Final fit and predictions for the 20 quiz cases.
final_rf <- randomForest(classe ~ ., data = dat, ntree = 750,
                         mtry = floor(sqrt(length(predictors))), importance = TRUE)
quiz_predictions <- predict(final_rf, test_raw[predictors])
predictions <- data.frame(problem_id = test_raw$problem_id,
                          prediction = as.character(quiz_predictions))
write.csv(predictions, file.path(data_dir, "quiz_predictions.csv"), row.names = FALSE)

importance_table <- data.frame(variable = rownames(importance(final_rf)),
                               MeanDecreaseAccuracy = importance(final_rf)[, "MeanDecreaseAccuracy"],
                               row.names = NULL)
importance_table <- importance_table[order(importance_table$MeanDecreaseAccuracy, decreasing = TRUE), ]

results <- list(
  n = nrow(dat), p = length(predictors), development_n = nrow(development), validation_n = nrow(validation),
  class_counts = table(dat$classe), cv_rf = cv_rf, cv_tree = cv_tree,
  cv_rf_mean = mean(cv_rf), cv_rf_sd = sd(cv_rf), cv_tree_mean = mean(cv_tree), cv_tree_sd = sd(cv_tree),
  rf_cm = rf_cm, tree_cm = tree_cm, rf_acc = rf_acc, tree_acc = tree_acc,
  rf_error = 1-rf_acc, acc_ci = acc_ci, error_ci = error_ci,
  final_oob_error = tail(final_rf$err.rate[, "OOB"], 1), importance_table = importance_table,
  predictions = predictions, predictors = predictors
)
saveRDS(results, file.path(data_dir, "analysis_results.rds"))

cat(sprintf("n=%d p=%d development=%d validation=%d\n", results$n, results$p, results$development_n, results$validation_n))
cat(sprintf("CV RF %.4f (SD %.4f); tree %.4f (SD %.4f)\n", results$cv_rf_mean, results$cv_rf_sd, results$cv_tree_mean, results$cv_tree_sd))
cat(sprintf("Validation RF %.4f; tree %.4f; RF error %.4f; final OOB error %.4f\n", results$rf_acc, results$tree_acc, results$rf_error, results$final_oob_error))
print(results$rf_cm)
print(results$predictions)
