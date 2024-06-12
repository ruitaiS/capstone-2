# Basic Hybrid Model
# Switch to white_always_wins

# Store Ratings Data Used Throughout Section 6
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating, moves, opening_eco)
# ------------------------------------------------------------------

tuning_results_0 <- data.frame(accuracy = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

for (cutoff in 0:cutoff_limit) { # Maintain previous Scale to plot all hybrid models together
#for (cutoff in 0:60) { # Zoomed
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return(1)
    }
  })
  
  accuracy <- calculate_accuracy(predicted, main_df$winner)
  tuning_results_0 <- rbind(tuning_results_0, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_0, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple", size = 1.5) + # remove size = 1.5 if zoomed
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") + # Comment out for zoomed
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Basic Hybrid Model") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting3.png", plot)

# Cleanup
rm(plot, predicted)