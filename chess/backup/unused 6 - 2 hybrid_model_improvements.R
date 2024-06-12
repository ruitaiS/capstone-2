# Comparison to Simpler Algorithms
white_always_wins <- calculate_accuracy(
  rep(1, nrow(main_df)),
  main_df$winner)
higher_rated_wins <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

aggregated_results <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean, na.rm = TRUE)
eco_winner <- function(opening_eco) {
  index <- match(opening_eco, aggregated_results$opening_eco)
  if (is.na(index)) {
    return(1)
  } else {
    mean_wr <- aggregated_results$winner[index]
    return(ifelse(mean_wr >= 0.5, 1, 0))
  }
}
  
#-------------------------------------------------------------------------------
# Tune Difference Cutoff By Checking Strength in Cutoff Group
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating, moves, opening_eco)

# Switch to Eco Winner
tuning_results_2 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
                               )
for (cutoff in 0:max(tuning_results$cutoff)) { # Maintain Previous Scale
  print(cutoff)
#for (cutoff in 0:60) { # Zoomed
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (eco_winner(row[['opening_eco']]))
    }
  })
  accuracy <- calculate_accuracy(unlist(predicted), main_df$winner)
  tuning_results_2 <- rbind(tuning_results_2, data.frame(
    accuracy = accuracy,
    cutoff = cutoff
    ))
}

rm(accuracy, cutoff, filtered_set_predictions, remaining_set_predictions, filtered, remaining)

# Test plot: -----
ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_line() +
  labs(title = "Multiple Line Plots",
       x = "X-axis",
       y = "Y-axis",
       color = "Count Cutoff") +
  theme_minimal()
# -----------------------------


plot <- ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple") + # use size = 1.5 if standard scaling
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") + # Comment out for zoomed
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Cutoff Subset Ensemble 2") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
store_plot("cutoff_subsetting_improved.png", plot)