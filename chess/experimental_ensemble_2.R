tuning_results_2 <- data.frame(accuracy = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in 0:max(tuning_results$cutoff)) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) > cutoff)
  remaining <- main_df[!(rownames(main_df) %in% rownames(filtered)), ]
  
  filtered_set_predictions <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  remaining_set_predictions <- rep(ifelse(mean(remaining$winner) >= 0.5, 1, 0), nrow(remaining))
  predicted <- c(filtered_set_predictions, remaining_set_predictions)
  
  accuracy <- calculate_accuracy(predicted, main_df$winner)
  tuning_results_2 <- rbind(tuning_results_2, data.frame(
    accuracy = accuracy,
    #dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(accuracy, cutoff, filtered_set_predictions, remaining_set_predictions, filtered, remaining)

# Comparison to Simpler Algorithms
by_majority_acc <- calculate_accuracy(
  rep(ifelse(mean(main_df$winner) >= 0.5, 1, 0), nrow(main_df)),
  main_df$winner)
by_rating_acc <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

plot <- ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") +
  #geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Cutoff Subset Ensembling")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
store_plot("cutoff_subsetting1.png", plot, h = 6, w = 6)

plot2 <- ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_point() +
  geom_line() +
  geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") +
  geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Cutoff Subset Ensembling") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot2)
store_plot("cutoff_subsetting2.png", plot2, h = 6, w = 6)