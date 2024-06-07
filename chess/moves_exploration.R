split_by_first_n_moves <- function(data, n) {
  results <- list()
  n_length_openers <- unique(lapply(data$moves, function(x) x[1:n])) 
  for (opener in n_length_openers) {
    # Subset the data where the first N moves match the current unique sequence
    #subset_df <- data[grep(paste0("^", move), data$moves), ]
    subset_df <- data[sapply(data$moves, function(x) all(x[1:n] == opener)), ]
    results[[opener]] <- subset_df
  }
  return(results)
}

split_data <- split_by_first_n_moves(train_df, 3)

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