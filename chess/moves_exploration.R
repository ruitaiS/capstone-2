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

# Histogram
num_rows <- sapply(split_data, function(df) nrow(df))

# Plot a histogram of the row counts
hist(num_rows, main = "Histogram of Number of Rows in Dataframes",
     xlab = "Number of Rows", ylab = "Frequency",
     col = "lightblue", border = "black")

# Mean Wins
wr <- sapply(split_data, function(df){
  mean(df$winner)
})