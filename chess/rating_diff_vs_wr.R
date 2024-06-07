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
       x = "White - Black Ratings",
       y = "White's Win Rate") +
  geom_smooth(method = "lm", se = FALSE, color = "red") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

store_plot("wr_by_rating_diff_filtered_regline.png", plot2, h = 6, w=6)

# Linear Model Predicting WR as a function of the rating difference
lm_model <- lm(wr ~ rating_diff, data = plot_df)
summary(lm_model)

rm(plot, plot2)