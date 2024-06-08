split_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = cut(avg_rating, breaks = seq(0, max(avg_rating) + 100, by = 100), include.lowest = TRUE, right = FALSE)) %>%
  split(.$rating_bin)%>%
  Filter(function(x) nrow(x) > 0, .)