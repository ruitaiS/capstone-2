# just assign rating bin with a func or something; this is too complicated and fancy

split_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = cut(avg_rating, breaks = seq(0, max(avg_rating) + 100, by = 100), include.lowest = TRUE, right = FALSE)) %>%
  split(.$rating_bin)%>%
  Filter(function(x) nrow(x) > 0, .)

bin_means <- lapply(split_data, function(df) {
  data.frame(
    rating_bin = unique(df$rating_bin),
    mean_winner = mean(df$winner)
  )
})

# Combine results into a single dataframe
bin_means_df <- do.call(rbind, bin_means)

# Step 3: Create the barplot
ggplot(bin_means_df, aes(x = rating_bin, y = mean_winner)) +
  geom_bar(stat = "identity") +
  labs(x = "Rating Bin", y = "Mean Winner", title = "Mean Winner per Rating Bin") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

#-------

bin_sizes <- lapply(split_data, function(df) {
  data.frame(
    rating_bin = unique(df$rating_bin),
    size = nrow(df)
  )
})

# Combine results into a single dataframe
bin_sizes_df <- do.call(rbind, bin_sizes)

# Step 3: Create the bar plot for bin sizes
ggplot(bin_sizes_df, aes(x = rating_bin, y = size)) +
  geom_bar(stat = "identity") +
  labs(x = "Rating Bin", y = "Size", title = "Size of Each Rating Bin") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) 