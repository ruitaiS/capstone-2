tuning_results_1 <- data.frame(accuracy = numeric(),
                               cutoff = numeric(),
                               stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating)

for (cutoff in 0:max(tuning_results$cutoff)) { # Maintain Previous Scale
  #for (cutoff in 0:60) { # Zoomed
  predicted <- apply(ratings, 1, function(row){
    if (row['diff'] >= cutoff) {
      return(ifelse(row['white_rating'] >= row['black_rating'], 1, 0))
    } else {
      return(1)
    }
  })
  
  accuracy <- calculate_accuracy(predicted, main_df$winner)
  tuning_results_1 <- rbind(tuning_results_1, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff, filtered_set_predictions, remaining_set_predictions, filtered, remaining)


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
