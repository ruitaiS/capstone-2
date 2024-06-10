count_cutoff <- seq(0, 200, 10)

# Apply count cutoff, and create a line graph for each of them

# Sample data
x <- 1:10
y1 <- x^2
y2 <- 2 * x
y3 <- sqrt(x)

# Create a dataframe
df <- data.frame(x = x, y1 = y1, y2 = y2, y3 = y3)

# Reshape data from wide to long format
df_long <- tidyr::pivot_longer(df, cols = c(y1, y2, y3), names_to = "Line", values_to = "Value")

# Plot
ggplot(df_long, aes(x = x, y = Value, color = Line)) +
  geom_line() +
  labs(title = "Multiple Line Plots",
       x = "X-axis",
       y = "Y-axis",
       color = "Lines") +
  theme_minimal()


# As the previous graph shows, there is a rating difference threshold,
# below which predicting the higher rated player as the winner will actually underperform
# in comparison to much simpler algorithms such as always predicting white.

# In the accuracy plot below, we predict the higher rated player as the winner
# for all rows where the rating difference was above the threshold.
# For the remaining rows,
# white was always predicted as the winner.

# As the graph shows, for a window of small rating differences,
# we can actually improve on predicting the higher rated 

tuning_results_3 <- data.frame(accuracy = numeric(),
                               cutoff = numeric(),
                               stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating)

#for (cutoff in 0:max(tuning_results$cutoff)) { # Maintain Previous Scale
for (cutoff in 0:60) { # Zoomed
  predicted <- apply(ratings, 1, function(row){
    if (row['diff'] >= cutoff) {
      return(ifelse(row['white_rating'] >= row['black_rating'], 1, 0))
    } else {
      use_bin_winner(row)
    }
  })
  
  accuracy <- calculate_accuracy(predicted, main_df$winner)
  tuning_results_3 <- rbind(tuning_results_3, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff, filtered_set_predictions, remaining_set_predictions, filtered, remaining)

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