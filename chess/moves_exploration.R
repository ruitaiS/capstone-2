split_dataframe_by_moves <- function(data, n) {
  results <- list()
  # Get unique sequences of moves up to n moves
  unique_moves <- unique(sapply(strsplit(data$moves, " "), function(x) paste(x[1:n], collapse = " ")))
  for (move in unique_moves) {
    subset_df <- data[grep(paste0("^", move), data$moves), ]
    results[[move]] <- subset_df
  }
  return(results)
}

split_data <- split_dataframe_by_moves(train_df, 3)

opening_seq <- data.frame(seq = names(split_data))
opening_seq$seq <- names(split_data)
opening_seq$count <- sapply(split_data, function(df) nrow(df))
opening_seq$wr <- sapply(split_data, function(df){mean(df$winner)})

top_sequences <- head(opening_seq[order(-opening_seq$count), ], 25)
# Plot a histogram of the row counts
plot <- ggplot(top_sequences, aes(x = seq, y = count)) +
  geom_bar(stat = "identity", fill = "skyblue", width = 0.5) +
  labs(x = "Sequence", y = "Count") +
  theme_minimal()