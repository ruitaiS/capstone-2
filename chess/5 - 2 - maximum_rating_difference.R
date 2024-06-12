# Subsetting by MAXIMUM rating difference
# Predict higher rated player wins
# only on games with rating difference smaller than X-axis value

tuning_results <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    # Cutoff now defines MAXIMUM rating diff, not minimum
    filter(abs(white_rating - black_rating) <= cutoff)
  predictions <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predictions, filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# First cutoff where higher player wins gives lower accuracy than guessing white for all
threshold <- max(tuning_results[which(tuning_results$accuracy < white_always_wins),]$cutoff)
plot <- ggplot(tuning_results, aes(x = cutoff)) +
  scale_x_reverse() +
  geom_rect(aes(xmin = -Inf, xmax = threshold, ymin = -Inf, ymax = Inf), fill = "gray", alpha = 0.2) +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  geom_line(aes(y = accuracy, color = "Predict Higher Rated Wins"), size = 1.5) +
  scale_color_manual(values = c("Predict Higher Rated Wins" = "blue"), guide = "none") +
  labs(x = "Maximum Rating Advantage", y = "") +
  ggtitle("Max Rating Advantage Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting2.png", plot)



# Additional Terminal Outputs:
#Print First cutoff where higher player wins gives lower accuracy than guessing white for all
head(tuning_results[which(tuning_results$accuracy < white_always_wins),], 1)

# Cleanup
rm(threshold, predictions, tuning_results)