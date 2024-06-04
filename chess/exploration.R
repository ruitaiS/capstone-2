# White vs. Black Rating
plot <- ggplot(main_df, aes(x = white_rating, y = black_rating, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("red", "blue"), labels = c("Black Wins", "White Wins")) +
  labs(title = "White Rating vs. Black Rating",
       x = "White Rating",
       y = "Black Rating",
       color = "Winner") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),          # General text size
    plot.title = element_text(size = unit(20, "mm")),    # Title text size
    axis.title = element_text(size = unit(15, "mm")),    # Axis titles text size
    axis.text = element_text(size = unit(10, "mm"))      # Axis text size
  )

store_plot("white_vs_black_ratings.png", plot, h = 6, w=6)
rm(plot)

# Win Percentage
# For these, filtered out games where white or black had fewer than 5 games as that color
plot_df <- merge(main_df, players[, c("white_wr", "overall_wr", "white_games", "player_id")],
                   by.x = "white_id", by.y = "player_id", all.x = TRUE)%>%
  merge(players[, c("black_wr", "overall_wr", "black_games", "player_id")],
        by.x = "black_id", by.y = "player_id", all.x = TRUE) %>%
  filter(white_games >= 5 & black_games >= 5)

plot <- ggplot(plot_df, aes(x = white_wr, y = black_wr, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("red", "blue"), labels = c("Black Wins", "White Wins")) +
  labs(title = "White WR vs. Black WR",
       x = "White's WR As White",
       y = "Black's WR As Black",
       color = "Winner") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),          # General text size
    plot.title = element_text(size = unit(20, "mm")),    # Title text size
    axis.title = element_text(size = unit(15, "mm")),    # Axis titles text size
    axis.text = element_text(size = unit(10, "mm"))      # Axis text size
  )

plot2 <- ggplot(plot_df, aes(x = overall_wr.x, y = overall_wr.y, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("red", "blue"), labels = c("Black Wins", "White Wins")) +
  labs(title = "White WR vs. Black WR",
       x = "White's Overall WR",
       y = "Black's Overall WR",
       color = "Winner") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),          # General text size
    plot.title = element_text(size = unit(20, "mm")),    # Title text size
    axis.title = element_text(size = unit(15, "mm")),    # Axis titles text size
    axis.text = element_text(size = unit(10, "mm"))      # Axis text size
  )

store_plot("white_vs_black_WR.png", plot, h = 6, w=6)
store_plot("white_vs_black_overall_WR.png", plot2, h = 6, w=6)
rm(plot, plot2)

# 