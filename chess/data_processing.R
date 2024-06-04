#> length(unique(train_df$opening_name))

#> length(unique(train_df$opening_eco))

# Unique Players Dataframe:
players <- data.frame(player_id = unique(c(train_df$white_id, train_df$black_id)))

# Player's Game Statistics
white_wins <- train_df %>%
filter(winner == 1) %>%
group_by(white_id) %>%
summarise(white_wins = n())

white_games <- train_df %>%
  group_by(white_id) %>%
  summarise(white_games = n())

black_wins <- train_df %>%
  filter(winner == 1) %>%
  group_by(black_id) %>%
  summarise(black_wins = n())

black_games <- train_df %>%
  group_by(black_id) %>%
  summarise(black_games = n())

players <- merge(players, white_wins, by.x = "player_id", by.y = "white_id", all.x = TRUE)
players <- merge(players, black_wins, by.x = "player_id", by.y = "black_id", all.x = TRUE)
players <- merge(players, white_games, by.x = "player_id", by.y = "white_id", all.x = TRUE)
players <- merge(players, black_games, by.x = "player_id", by.y = "black_id", all.x = TRUE)

# Convert NA wins to 0 if they've played on that side
# Distinguish from 0 wins to never played
players$white_wins[!is.na(players$white_games) & is.na(players$white_wins)] <- 0
players$black_wins[!is.na(players$black_games) & is.na(players$black_wins)] <- 0

players$white_wr <- players$white_wins/players$white_games
players$black_wr <- players$black_wins/players$black_games
players$overall_wr <- (coalesce(players$white_wins, 0) + coalesce(players$black_wins, 0))/(coalesce(players$white_games, 0) + coalesce(players$black_games, 0))

rm(white_wins, white_games, black_wins, black_games)