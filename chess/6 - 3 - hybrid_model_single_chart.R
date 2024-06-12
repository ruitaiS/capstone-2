# Combine all tuning_results dataframes into a single chart

combined_results <- rbind(
  transform(tuning_results_0, source = "white_always_wins"),
  transform(tuning_results_1, source = "rating_bin_winner"),
  transform(tuning_results_2, source = "eco_winner")
)

# Plotting with combined data
plot <- ggplot(combined_results, aes(x = cutoff, y = accuracy, color = source)) +
  geom_line() +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy", color = "Source") +
  ggtitle("Hybrid Models Combined") +
  scale_x_reverse() +
  theme_minimal() +
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting_combined.png", plot)

rm(plot, combined_results)

# Determining Optimal Value to Set the Cutoff
best_cutoffs <- head(tuning_results_2[order(tuning_results_2$accuracy, decreasing = TRUE), ])