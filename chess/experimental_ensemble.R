# If the rating difference is larger than a threshold, guess that stronger player wins
# Else, examine the moves / openers

tuning_results <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in 1:max(abs(main_df$white_rating - main_df$black_rating))-1) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) > cutoff)
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

rm(cutoff, accuracy, filtered, predicted)

plot <- ggplot(tuning_results, aes(x = cutoff)) +
  geom_point(aes(y = accuracy, color = "Accuracy")) +
  geom_line(aes(y = accuracy, color = "Accuracy")) +
  geom_point(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset")) +  # Dataset percentage plot
  geom_line(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset")) +
  scale_color_manual(values = c("Accuracy" = "blue", "Percentage of Dataset" = "red"), guide = guide_legend(title = "")) +  # Define color scale
  labs(x = "Minimum Rating Difference", y = "") +
  ggtitle("Minimum Rating Difference Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
store_plot("cutoff_subsetting0.png", plot)

# Third Graph Including Misleading Product
#ggplot(tuning_results, aes(x = cutoff)) +
#  geom_point(aes(y = accuracy, color = "Accuracy")) +  # Accuracy plot
#  geom_line(aes(y = accuracy, color = "Accuracy")) +
#  geom_point(aes(y = dataset_size/nrow(main_df), color = "Dataset Percentage")) +  # Dataset percentage plot
#  geom_line(aes(y = dataset_size/nrow(main_df), color = "Dataset Percentage")) +
#  geom_point(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Dataset Percentage")) +  # Product plot
#  geom_line(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Dataset Percentage")) +
#  scale_color_manual(values = c("Accuracy" = "blue", "Dataset Percentage" = "red", "Accuracy * Dataset Percentage" = "green")) +  # Define color scale
#  labs(x = "Rating Difference Cutoff", y = "") +
#  ggtitle("") +
#  theme(legend.position = "right")