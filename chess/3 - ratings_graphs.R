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

print(plot)
#store_plot("white_wr_by_game_rating.png", plot)

# White vs. Black Rating
plot <- ggplot(main_df, aes(x = white_rating, y = black_rating, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("blue", "red"), labels = c("Black", "White")) +
  labs(title = "White Vs. Black Ratings ",
       x = "White's Rating",
       y = "Black's Rating",
       color = "Winner") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", size=1.5, color = "green") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("white_vs_black_ratings.png", plot, h = 6, w=6)
#rm(plot)

#----------------------------------------------------------------------------------------
# White's WR vs. Rating Advantage
plot_df <- main_df %>%
  mutate(rating_diff = white_rating - black_rating) %>%
  select(rating_diff, winner) %>%
  group_by(rating_diff) %>%
  mutate(count = n()) %>%
  ungroup() %>%
  filter(count >= 5) %>% # Cleans up noise at edges and increments
  aggregate(winner ~ rating_diff, data = ., FUN = mean) %>%
  setNames(c("rating_diff", "wr"))


plot <- ggplot(plot_df, aes(x = rating_diff, y = wr)) +
  geom_point() +
  labs(title = "Rating Difference Vs. Win Rate",
       x = "White Minus Black Rating Difference",
       y = "White's Win Rate") +
  geom_smooth(method = "lm", se = FALSE, color = "red")+
  ylim(-0, 1) +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("wr_by_rating_diff_filtered_regline.png", plot, h = 6, w=6)
rm(plot, plot_df)