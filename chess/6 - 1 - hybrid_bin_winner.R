# Hybrid Model Improvement 1
# Switch to Rating Bin Winner

summary_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = floor(avg_rating / 100) * 100,
         ) %>%
  group_by(rating_bin) %>%
  summarize(bin_mean = mean(winner),
            bin_count = n())

bin_winner <- function(white_rating, black_rating){
  avg_rating <- (white_rating + black_rating) / 2
  rating_bin <- floor(avg_rating / 100)*100
  
  match_index <- which(summary_data$rating_bin == rating_bin)
  
  if (length(match_index)>0){
    return (ifelse(summary_data[match_index,]$bin_mean >= 0.5, 1, 0))
  }else{
    return (as.integer(1))
  }
}
  
#-------------------------------------------------------------------------------

tuning_results_1 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
                               )

for (cutoff in 0:cutoff_limit) {
  print(cutoff)
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (bin_winner(row[['white_rating']], row[['black_rating']]))
    }
  })
  accuracy <- calculate_accuracy(unlist(predicted), main_df$winner)
  tuning_results_1 <- rbind(tuning_results_1, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_1, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple") +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Hybrid Model 1") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)

# Cleanup
rm(summary_data, bin_winner, plot, predicted)