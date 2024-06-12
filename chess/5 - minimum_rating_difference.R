# Subsetting by MINIMUM rating difference
# Predict higher rated player wins
# only on games with rating difference larger than X-axis value

tuning_results <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in 1:max(abs(main_df$white_rating - main_df$black_rating))-1) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) >= cutoff)
  predicted <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predicted, filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
  if (accuracy == 1) {
    # Any rating difference greater than the current cutoff will yield perfect results 
    # Increasing cutoff past here will only decrease dataset size
    break
  }
}

# Save Cutoff for later graphs
cutoff_limit <- max(tuning_results$cutoff)
rm(cutoff, accuracy, filtered, predicted)

plot <- ggplot(tuning_results, aes(x = cutoff)) +
  geom_line(aes(y = accuracy, color = "Accuracy"), size=1.5) +
  geom_line(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Percentage"), size=1.5) +
  geom_line(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset"), size=1.5) +
  scale_color_manual(values = c("Accuracy" = "blue", "Percentage of Dataset" = "red", "Accuracy * Percentage" = "green"),
                     breaks = c("Accuracy", "Percentage of Dataset", "Accuracy * Percentage")) +
  labs(x = "Minimum Rating Advantage", y = "") +
  ggtitle("Minimum Rating Advantage Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting1.png", plot)

rm(plot, tuning_results)