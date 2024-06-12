
# But for very small rating differences, the higher rated player might only be better on paper.
# In the graph below, instead of subsetting by rows where the rating difference is GREATER
# than a given cutoff, we're subsetting by rows where the difference is SMALLER than the cutoff.
# As the graph shows, the smaller the rating difference, the less predictive power the metric holds -
# For very small rating differences, it is about as good as random guessing,
# and it actually underperforms compared to guessing 1 for everything, shown by the dashed red line
# (Note this assumes the proportion of white wins holds constant
# for any set of games where skill is equally distributed among white and black players)

tuning_results_2 <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
#for (cutoff in max(abs(main_df$white_rating - main_df$black_rating)):1-1) {
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    # Cutoff now defines MAXIMUM rating diff, not minimum
    filter(abs(white_rating - black_rating) <= cutoff)
  predictions <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predictions, filtered$winner)
  tuning_results_2 <- rbind(tuning_results_2, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# Comparison to Simpler Algorithms
white_always_wins <- calculate_accuracy(
  rep(1, nrow(main_df)),
  main_df$winner)
higher_rated_wins <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

# First cutoff where higher player wins gives lower accuracy than guessing white for all
threshold <- max(tuning_results_2[which(tuning_results_2$accuracy < white_always_wins),]$cutoff)

# More Information on Threshold:
tuning_results_2[which(tuning_results_2$accuracy < white_always_wins),]

plot <- ggplot(tuning_results_2, aes(x = cutoff)) +
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