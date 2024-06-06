split_dataframe_by_moves <- function(data, N) {
  # Initialize an empty list to store the resulting dataframes
  df_list <- list()
  
  # Get unique sequences of moves up to N moves
  unique_moves <- unique(sapply(strsplit(data$moves, " "), function(x) paste(x[1:N], collapse = " ")))
  
  # Loop through each unique sequence of moves
  for (move in unique_moves) {
    # Subset the data where the first N moves match the current unique sequence
    subset_df <- data[grep(paste0("^", move), data$moves), ]
    
    # Store the subset dataframe in the list
    df_list[[move]] <- subset_df
  }
  
  # Return the list of dataframes
  return(df_list)
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