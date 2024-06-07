# Predict Based on Dataset Average
predictions <- rep(ifelse(mean(train_df$winner) >= 0.5, 1, 0), length(test_df$winner))

# Display the predictions
print(predictions)

# Now you can use the compare function
compare(predictions, test_df$winner)

# Predict Higher Rated Player Wins:

# Higher Rated Player, Skewed by Win Rate on That side

# More likely side based on opening ECO

# More likely side based on opening name

