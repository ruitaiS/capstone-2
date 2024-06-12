# Showing the proportion of white wins holds constant
# for any set of games (assuming skill is equally distributed among white and black players)

tuning_results <- data.frame(guess_white_accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Plot accuracy of "white wins" against the same cutoffs as "higher rated wins"
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) <= cutoff)
  guess_white_accuracy <- calculate_accuracy(rep(1, nrow(filtered)), filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    guess_white_accuracy = guess_white_accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# Subsetting has negligible effect on white's win rate:
plot <- ggplot(tuning_results, aes(x = cutoff)) +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_line(aes(y = guess_white_accuracy, color = "Predict White Wins")) +
  scale_color_manual(values = c("Predict White Wins" = "red"), guide = "none") +
  scale_x_reverse() +
  labs(x = "Maximum Rating Advantage", y = "") +
  ggtitle("Max Rating Advantage Subsetting") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting2-white_wins.png", plot)

# Cleanup
rm(guess_white_accuracy, plot, tuning_results)