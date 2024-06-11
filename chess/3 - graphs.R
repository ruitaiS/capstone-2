# White's WR Vs. Average Rating of the two players:
plot_df <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2) %>%
  select(avg_rating, winner) %>%
  group_by(avg_rating) %>%
  summarize(white_wr = mean(winner, na.rm = TRUE))

plot <- ggplot(plot_df, aes(x = avg_rating, y = white_wr)) +
  geom_point() +
  #geom_line() +
  labs(title = "White Win Rate by Game Rating",
       x = "Game Rating",
       y = "White's Win Rate") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

store_plot("white_wr_by_game_rating.png", plot)