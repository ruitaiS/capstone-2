###############
# Initial Setup
###############

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(ggplot2)) install.packages("ggplot2", repos = "http://cran.us.r-project.org")
if(!require(tidyr)) install.packages("tidyr", repos = "http://cran.us.r-project.org")
if(!require(dplyr)) install.packages("dplyr", repos = "http://cran.us.r-project.org")
if(!require(lubridate)) install.packages("lubridate", repos = "http://cran.us.r-project.org")

library(tidyverse)
library(caret)
library(ggplot2)
library(tidyr)
library(dplyr)
library(lubridate)
options(timeout = 120)

# Set working directory to the directory containing this script
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Check for movies and ratings files
data_file = "../datasets/games.csv"
if(!(file.exists(data_file))){
  print("Please extract the contents of the following dataset to the datasets folder")
  print("https://www.kaggle.com/datasets/datasnaek/chess?resource=download")
  stop("Missing dataset")
}

data <- read.csv(data_file)
names(data) <- tolower(names(data))
rm(data_file)

# Only Definitive Wins
data <- filter(data, winner != "draw")

# Encode winner column
data$winner <- ifelse(data$winner == "black", 0, 1)

# Only Rated games
data$rated <- tolower(data$rated)
data <- filter(data, rated == 'true')

# Remove Unnecessary Columns
data <- select(data, subset = -c(id, rated, created_at, last_move_at, increment_code))

# Ignore Ratings Information
#data <- select(data, subset = -c(white_rating, black_rating, rated))

# Only Players who have played both sides
#common_ids <- intersect(unique(data$white_id), unique(data$black_id))
#data <- data[data$white_id %in% common_ids & data$black_id %in% common_ids, ]

###################################################
# Create main and final_holdout_test sets 
# Note: this process could take a couple of minutes
###################################################
# Final hold-out test set will be 10% of data
# TODO: Probably a more elegant way to partition this into 3 parts
set.seed(1, sample.kind="Rounding") # if using R 3.6 or later
# set.seed(1) # if using R 3.5 or earlier
holdout_index <- createDataPartition(y = data$winner, times = 1, p = 0.1, list = FALSE)

# Make sure we have match data for the color they're playing as
# Used for main / holdout split, and also for each fold
validate <- function(test, train){
  # Note it makes the test set much smaller
  # Can be improved by checking if test set has more than one row as that color,
  # and moving some proportion over to the train set (as opposed to all)
  
  updated_test <- test %>% 
    semi_join(train, by = "white_id") %>%
    semi_join(train, by = "black_id")
  updated_train <- rbind(train, anti_join(test, updated_test))
  return (list(updated_test, updated_train))
}

results <- validate(data[holdout_index, ], data[-holdout_index,])
final_holdout_test <- results[[1]]
main_df <- results[[2]]
rm(results, holdout_index, data)

# K-fold Cross Validation; k = 5
folds <- createFolds(main_df$winner, k = 5, list = TRUE, returnTrain = FALSE)
generate_splits <- function(index){
  return (validate(main_df[folds[[index]],], main_df[-folds[[index]],]))
  #return (list(data[folds[[index]],],
  #                 data[-folds[[index]],]))
}

# Split Along Fold (Pick New Index Each Run)
splits <- generate_splits(index=1)
test_df <- splits[[1]]
train_df <- splits[[2]]
rm(splits)

#########################################################

# Storing Results:
results_df <- data.frame(Algorithm = character(),
                      Accuracy = numeric(),
                      stringsAsFactors = FALSE)

# Accuracy Calculation Function:
calculate_accuracy <- function(predicted_outcomes, actual_outcomes) {
  return(mean(predicted_outcomes == actual_outcomes))
}

store_plot<- function(filename, plot, h = 6, w = 12) {
  res <- 300
  height <- h * res
  width <- w * res
  png(file = paste("graphs/", filename, sep = ""), height = height, width = width, res = res)
  print(plot)
  dev.off()
}



