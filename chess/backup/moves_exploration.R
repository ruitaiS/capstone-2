split_data <- main_df %>%
  mutate(first_three_elements = sapply(moves, function(x) paste(head(x, 3), collapse = ","))) %>%
  split(.$first_three_elements)

opening_seq <- data.frame(seq = names(split_data))
opening_seq$count <- sapply(split_data, function(df) nrow(df))
opening_seq$wr <- sapply(split_data, function(df){mean(df$winner)})
opening_seq$avg_white_rating <- sapply(split_data, function(df){mean(df$white_rating)})
opening_seq$avg_black_rating <- sapply(split_data, function(df){mean(df$black_rating)})
opening_seq$rating_diff <- sapply(split_data, function(df){mean(df$white_rating - df$black_rating)})

winning_openers <- 
losing_openers <- 

top_sequences <- head(opening_seq[order(-opening_seq$count), ], 25)
# Plot a histogram of the row counts
plot <- ggplot(top_sequences, aes(x = seq, y = count)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.5) +
  labs(x = "Sequence", y = "Count") +
  theme_minimal()