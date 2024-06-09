
# But for very small rating differences, the higher rated player might only be better on paper.
# In the graph below, instead of subsetting by rows where the rating difference is GREATER
# than a given cutoff, we're subsetting by rows where the difference is SMALLER than the cutoff.
# As the graph shows, the smaller the rating difference, the less predictive power the metric holds -
# For very small rating differences, it is about as good as random guessing,
# and it actually underperforms compared to guessing 1 for everything, shown by the dashed red line
# (Note this assumes the proportion of white wins holds constant
# for any set of games where skill is equally distributed among white and black players)



tuning_results_2 <- data.frame(higher_rating_accuracy = numeric(),
                               guess_white_accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
#for (cutoff in max(abs(main_df$white_rating - main_df$black_rating)):1-1) {
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    # Cutoff now defines MAXIMUM rating diff, not minimum
    filter(abs(white_rating - black_rating) <= cutoff)
  higher_rating_predictions <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  higher_rating_accuracy <- calculate_accuracy(higher_rating_predictions, filtered$winner)
  guess_white_accuracy <- calculate_accuracy(rep(1, nrow(filtered)), filtered$winner)
  tuning_results_2 <- rbind(tuning_results_2, data.frame(
    higher_rating_accuracy = higher_rating_accuracy,
    guess_white_accuracy = guess_white_accuracy,
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

plot <- ggplot(tuning_results_2, aes(x = cutoff)) +
  geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") +
  geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
  #geom_point(aes(y = accuracy, color = "Accuracy")) +
  geom_line(aes(y = higher_rating_accuracy, color = "Predict Higher Rated Wins"), size = 1.5) +
  #geom_line(aes(y = guess_white_accuracy, color = "Predict White Wins")) +
  #scale_color_manual(values = c("Predict Higher Rated Wins" = "blue", "Predict White Wins" = "red")) +
  scale_color_manual(values = c("Predict Higher Rated Wins" = "blue"), guide = "none") +
  scale_x_reverse() +
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
store_plot("cutoff_subsetting2.png", plot)

# Subsetting has negligible effect on white's win rate:
#plot2 <- ggplot(tuning_results_2, aes(x = cutoff)) +
#  geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") +
#  geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
#  #geom_point(aes(y = accuracy, color = "Accuracy")) +
#  #geom_line(aes(y = higher_rating_accuracy, color = "Predict Higher Rated Wins"), size = 1.5) +
#  geom_line(aes(y = guess_white_accuracy, color = "Predict White Wins")) +
#  #scale_color_manual(values = c("Predict Higher Rated Wins" = "blue", "Predict White Wins" = "red")) +
#  scale_color_manual(values = c("Predict White Wins" = "red")) +
#  scale_x_reverse() +
#  labs(x = "Maximum Rating Advantage", y = "") +
#  ggtitle("Max Rating Advantage Subsetting") +
#  theme(legend.position = "right")+
#  theme_minimal()+
#  theme(
#    text = element_text(size = unit(10, "mm")),
#    plot.title = element_text(size = unit(20, "mm")),
#    axis.title = element_text(size = unit(15, "mm")),
#    axis.text = element_text(size = unit(10, "mm"))
#  )

#print(plot2)
#store_plot("cutoff_subsetting2-white_wins.png", plot2)