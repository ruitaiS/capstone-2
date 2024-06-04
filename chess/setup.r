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

# Only Definitive Wins
data <- filter(data, winner != "draw")
data$winner <- ifelse(data$winner == "black", 0, 1)

# Only Rated games
data$rated <- tolower(data$rated)
data <- filter(data, rated == 'true')

# Ignore Ratings Information
#data <- select(data, subset = -c(white_rating, black_rating, rated))

# Only Players who have played both sides
#common_ids <- intersect(unique(data$white_id), unique(data$black_id))
#data <- data[data$white_id %in% common_ids & data$black_id %in% common_ids, ]
# Preprocessing


###################################################
# Create main and final_holdout_test sets 
# Note: this process could take a couple of minutes
###################################################
# Final hold-out test set will be 10% of data
# TODO: Probably a more elegant way to partition this into 3 parts
set.seed(1, sample.kind="Rounding") # if using R 3.6 or later
# set.seed(1) # if using R 3.5 or earlier
holdout_index <- createDataPartition(y = data$sex, times = 1, p = 0.1, list = FALSE)
holdout_df <- data[holdout_index,]
test_index <- createDataPartition(y = data[-holdout_index,]$sex, times = 1, p = 0.2, list = FALSE)
train_df <- data[-test_index,]
test_df <- data[test_index,]

rm(data, holdout_index, test_index, data_file_1, data_file_2)

#########################################################

# DF for Storing RMSE Results:
results_df <- data.frame(Algorithm = character(),
                      Accuracy = numeric(),
                      stringsAsFactors = FALSE)

# RMSE Calculation Function:
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



