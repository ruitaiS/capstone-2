tuning_results3 <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in 1:max(abs(main_df$white_rating - main_df$black_rating))-1) {
  filtered <- main_df %>%
    # Cutoff now defines MAXIMUM rating diff, not minimum
    filter(abs(white_rating - black_rating) < cutoff)
  predicted <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predicted, filtered$winner)
  tuning_results3 <- rbind(tuning_results3, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# Comparison to Simpler Algorithms
by_majority_acc <- calculate_accuracy(
  rep(ifelse(mean(main_df$winner) >= 0.5, 1, 0), nrow(main_df)),
  main_df$winner)
by_rating_acc <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

plot <- ggplot(tuning_results3, aes(x = cutoff)) +
  geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") +
  geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
  geom_point(aes(y = accuracy, color = "Accuracy")) +
  geom_line(aes(y = accuracy, color = "Accuracy")) +
  scale_color_manual(values = c("Accuracy" = "blue"), guide = "none") +
  labs(x = "Maximum Rating Difference", y = "") +
  ggtitle("Max Rating Difference Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
store_plot("cutoff_subsetting3.png", plot)