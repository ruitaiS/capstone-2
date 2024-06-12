# White vs. Black Rating
plot <- ggplot(main_df, aes(x = white_rating, y = black_rating, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("blue", "red"), labels = c("Black", "White")) +
  labs(title = "White Vs. Black Ratings ",
       x = "White's Rating",
       y = "Black's Rating",
       color = "Winner") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

store_plot("white_vs_black_ratings.png", plot, h = 6, w=6)
rm(plot)