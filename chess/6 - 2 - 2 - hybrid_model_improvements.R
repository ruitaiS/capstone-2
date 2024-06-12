bin_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = floor(avg_rating / 100) * 100,
         )

summary_data <- bin_data %>%
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



# Apply count cutoff, and create a line graph for each of them
  
#-------------------------------------------------------------------------------
# Tune Difference Cutoff By Checking Strength in Cutoff Group
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating, moves)

# Switch to Rating Bin Winner
tuning_results_3 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
                               )


for (cutoff in 0:max(tuning_results$cutoff)) { # Maintain Previous Scale
#for (cutoff in 0:60) { # Zoomed
  print(cutoff)
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (bin_winner(row[['white_rating']], row[['black_rating']]))
    }
  })
  accuracy <- calculate_accuracy(unlist(predicted), main_df$winner)
  tuning_results_3 <- rbind(tuning_results_3, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff, filtered_set_predictions, remaining_set_predictions, filtered, remaining)

# Test plot: -----
ggplot(tuning_results_4, aes(x = cutoff, y = accuracy, color = count_cutoff)) +
  geom_line() +
  labs(title = "Multiple Line Plots",
       x = "X-axis",
       y = "Y-axis",
       color = "Count Cutoff") +
  theme_minimal()
# -----------------------------


plot <- ggplot(tuning_results_3, aes(x = cutoff, y = accuracy)) +
  #geom_point() +
  geom_line(color = "purple") + # use size = 1.5 if standard scaling
  #geom_hline(yintercept = by_majority_acc, linetype = "dashed", color = "red") + # Comment out for zoomed
  geom_hline(yintercept = by_rating_acc, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Cutoff Subset Ensemble Zoomed") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
store_plot("cutoff_subsetting3_zoomed.png", plot)