# Comparison to Simpler Algorithms
white_always_wins <- calculate_accuracy(
  rep(1, nrow(main_df)),
  main_df$winner)
higher_rated_wins <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

# Combine all tuning_results_x dataframes into a single dataframe
combined_results <- rbind(
  transform(tuning_results_1, source = "white_always_wins"),
  transform(tuning_results_2, source = "eco_winner"),
  transform(tuning_results_3, source = "rating_bin_winner")#,
  #transform(tuning_results_4, source = "")
)

# Plotting with combined data
plot <- ggplot(combined_results, aes(x = cutoff, y = accuracy, color = source)) +
  geom_line() +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy", color = "Source") +
  ggtitle("Cutoff Subset Ensemble Combined") +
  scale_x_reverse() +
  theme_minimal() +
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

# Display the plot
print(plot)

store_plot("cutoff_subsetting_combined.png", plot)