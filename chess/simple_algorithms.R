observed <- test_df$winner

# Predict Based on Dataset's Majority Winner
predicted <- rep(ifelse(mean(train_df$winner) >= 0.5, 1, 0), length(test_df$winner))
results <- rbind(results, data.frame(
  Algorithm = "Majority Train Set Winner",
  Accuracy = calculate_accuracy(
    predicted,
    test_df$winner),
  Fold = fold_index))

#cf1 <- cf(predicted, observed)
#print(cf1)

# Predict Higher Rated Player Wins:
predicted <- ifelse(test_df$white_rating >= test_df$black_rating, 1, 0)
results <- rbind(results, data.frame(
  Algorithm = "Higher Rated Wins",
  Accuracy = calculate_accuracy(
    predicted,
    test_df$winner),
  Fold = fold_index))

cf2 <- cf(predicted, observed)
print(cf2)

# Higher Rated Player, Skewed by Win Rate on That side

# More likely side based on opening ECO

# More likely side based on opening name

