# Ratings vs. Wins
plot <- ggplot(data, aes(x = white_rating, y = black_rating, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("red", "blue"), labels = c("Black Wins", "White Wins")) +
  labs(title = "White Rating vs. Black Rating",
       x = "White Rating",
       y = "Black Rating",
       color = "Winner") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),          # General text size
    plot.title = element_text(size = unit(20, "mm")),    # Title text size
    axis.title = element_text(size = unit(15, "mm")),    # Axis titles text size
    axis.text = element_text(size = unit(10, "mm"))      # Axis text size
  )

store_plot("white_vs_black_ratings.png", plot, h = 6, w=6)
rm(plot)