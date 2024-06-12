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

# Higher Rated Player, Skewed by Win Rate on That side

# More likely side based on opening ECO

# More likely side based on opening name

