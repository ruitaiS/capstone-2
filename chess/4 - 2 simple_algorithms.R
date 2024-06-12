# Random Guess
set.seed(1)
predicted <- sample(0:1, length(main_df$winner), replace = TRUE)
results <- rbind(results, data.frame(
  Algorithm = "Random Guess",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Predict White to Win Every Match
predicted <- rep(1, length(main_df$winner))
results <- rbind(results, data.frame(
  Algorithm = "White Always Wins",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Predict Higher Rated Player Wins:
predicted <- ifelse(main_df$white_rating >= main_df$black_rating, 1, 0)
results <- rbind(results, data.frame(
  Algorithm = "Higher Rated Wins",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Store into Environment For Later ---------------------------
white_always_wins <- calculate_accuracy(
  rep(1, nrow(main_df)),
  main_df$winner)
higher_rated_wins <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

# Cleanup
rm(predicted, predictions)