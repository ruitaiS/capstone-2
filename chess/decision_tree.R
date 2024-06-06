library(rpart)

dt_df <- train_df[order(train_df$moves), ]

# Train the decision tree model
decision_tree <- rpart(winner ~ ., data = dt_df, method = "class")

# Print the decision tree
print(decision_tree)

# Plot the decision tree
plot(decision_tree)
text(decision_tree, pretty = 0)