model <- glm(winner ~ white_rating-black_rating, data = main_df, family = binomial)

# Summary of the model
summary(model)

# Extract coefficients
intercept <- model$coefficients["(Intercept)"]
slope <- model$coefficients["rating_diff"]

# Function to calculate the cutoff black rating given white rating
cutoff_black_rating <- function(white_rating) {
  return ((-intercept / slope) + white_rating)
}

# Create a sequence of white ratings for plotting the decision boundary
white_ratings_seq <- seq(min(main_df$white_rating), max(main_df$white_rating), length.out = 100)

# Calculate corresponding black ratings for the decision boundary
black_ratings_seq <- cutoff_black_rating(white_ratings_seq)

boundary_df <- data.frame(white_rating = white_ratings_seq, black_rating = black_ratings_seq)

# Plot the data
plot <- ggplot(main_df, aes(x = white_rating, y = black_rating, color = as.factor(winner))) +
  geom_point(size = 3) +
  labs(title = "Decision Boundary for Winning Prediction", x = "White Rating", y = "Black Rating") +
  scale_color_manual(values = c("black", "lightgray")) +
  theme_minimal() +
  theme(legend.position = "top") +
  geom_line(data = boundary_df, aes(x = white_rating, y = black_rating), color = "red")

# Display the plot
store_plot("rating_decision_boundary.png", plot)