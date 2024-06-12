# Hybrid Model Improvement 2
# Switch to ECO group winner

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
tuning_results_2 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
)
for (cutoff in 0:cutoff_limit) { # Maintain Previous Scale
  print(cutoff)
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

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple") +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Hybrid Model 2") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting_improved.png", plot)

# Cleanup
rm(plot, predicted, aggregated_results, eco_winner)
