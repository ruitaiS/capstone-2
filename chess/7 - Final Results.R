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

# ----------
aggregated_results <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean, na.rm = TRUE)
eco_winner <- function(opening_eco) {
  index <- match(opening_eco, aggregated_results$opening_eco)
  if (is.na(index)) {
    return (1)
  } else {
    mean_wr <- aggregated_results$winner[index]
    return (ifelse(mean_wr >= 0.5, 1, 0))
  }
}

# ----------
# Static Models
white_always_wins_accuracy <- calculate_accuracy(rep(1, nrow(final_holdout_test)), final_holdout_test$winner)

higher_rated_wins_accuracy <- calculate_accuracy(
  ifelse(final_holdout_test$white_rating >= final_holdout_test$black_rating, 1, 0),
  final_holdout_test$winner)

# Hybrid Models
threshold <- (69+52)/2
white_wins_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (1)
  }
}), final_holdout_test$winner)

rating_bin_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (bin_winner(row[['white_rating']], row[['black_rating']]))
  }
}), final_holdout_test$winner)

eco_winner_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (eco_winner(row[['opening_eco']]))
  }
}), final_holdout_test$winner)

# Store Results

algorithm_names <- c("White Wins Accuracy",
                     "Higher Rated Wins Accuracy",
                     "White Wins Hybrid",
                     "Rating Bin Hybrid",
                     "ECO Winner Hybrid")
accuracies <- c(white_wins_accuracy, higher_rated_wins_accuracy, white_wins_hybrid, rating_bin_hybrid, eco_winner_hybrid)

# Create the data frame
results <- data.frame(Algorithm = algorithm_names, Accuracy = accuracies)


#-------
results_final <- data.frame(accuracy = numeric(),
                               cutoff = numeric(),
                            source = character()
)

for (cutoff in 0:cutoff_limit) {
  print(cutoff)
  
  #predicted <- apply(final_holdout_test, 1, function(row){
  #  if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
  #    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  #  } else {
  #    return (eco_winner(row[['opening_eco']]))
  #  }
  #})
  #accuracy <- calculate_accuracy(unlist(predicted), final_holdout_test$winner)
  
  white_wins_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (1)
    }
  }), final_holdout_test$winner)
  
  rating_bin_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (bin_winner(row[['white_rating']], row[['black_rating']]))
    }
  }), final_holdout_test$winner)
  
  eco_winner_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (eco_winner(row[['opening_eco']]))
    }
  }), final_holdout_test$winner)
  
  
  
  results_final <- rbind(results_final, data.frame(
    accuracy = white_wins_hybrid,
    cutoff = cutoff,
    source = "White Wins Hybrid"))
  results_final <- rbind(results_final, data.frame(
    accuracy = rating_bin_hybrid,
    cutoff = cutoff,
    source = "Rating Bin Hybrid"))
  results_final <- rbind(results_final, data.frame(
    accuracy = eco_winner_hybrid,
    cutoff = cutoff,
    source = "Eco Winner Hybrid"))
}

rm(accuracy, cutoff)

plot <- ggplot(results_final, aes(x = cutoff, y = accuracy, color = source)) +
  geom_line() +
  geom_hline(yintercept = white_always_wins_accuracy, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins_accuracy, linetype = "dashed", color = "blue") +
  geom_vline(xintercept = threshold, linetype = "dashed") +
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
store_plot("final_hybrid_2.png", plot)

# ----
test <- apply(final_holdout_test, 1, function(row){
  if ((row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return (ifelse(row[['white_rating']] >= row[['black_rating']], "rating 1", "rating 0"))
  } else {
    return ("ww") #(1)
  }
})