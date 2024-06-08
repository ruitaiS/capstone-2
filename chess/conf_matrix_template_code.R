confusion_matrix_stats <- list()

# Iterate over each model
for (model_name in names(models)) {
  # Calculate confusion matrix
  conf_matrix <- confusionMatrix(models[[model_name]]$predicted, models[[model_name]]$actual)
  
  # Extract relevant statistics
  stats <- data.frame(
    model = model_name,
    accuracy = conf_matrix$overall["Accuracy"],
    sensitivity = conf_matrix$byClass["Sensitivity"],
    specificity = conf_matrix$byClass["Specificity"],
    precision = conf_matrix$byClass["Pos Pred Value"],
    recall = conf_matrix$byClass["Recall"],
    F1_score = conf_matrix$byClass["F1"]
  )
  
  # Append statistics to the list
  confusion_matrix_stats[[model_name]] <- stats
}

# Combine statistics from all models into a single dataframe
combined_stats <- do.call(rbind, confusion_matrix_stats)

# Print the combined statistics
print(combined_stats)