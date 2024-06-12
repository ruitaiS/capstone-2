bin_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = floor(avg_rating / 100) * 100,
         opening_three = map_chr(moves, ~ paste(.x[1:3], collapse = " ")))

summary_data <- bin_data %>%
  group_by(rating_bin, opening_three) %>%
  summarize(bin_mean = mean(winner),
            bin_count = n())

# bar plot of bin means
ggplot(unique(bin_data[, c("rating_bin", "bin_mean")]), aes(x = rating_bin, y = bin_mean)) +
  geom_bar(stat = "identity") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  labs(x = "Rating Bin", y = "White WR", title = "White WR per Rating Bin") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#-------

# bar plot for bin sizes
ggplot(bin_sizes_df, aes(x = rating_bin, y = size)) +
  geom_bar(stat = "identity") +
  labs(x = "Rating Bin", y = "Size", title = "Size of Each Rating Bin") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 