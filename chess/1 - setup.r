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

# Store moves as list
data$moves <- lapply(strsplit(data$moves, " "), as.character)

# Only Rated games
data$rated <- tolower(data$rated)
data <- filter(data, rated == 'true')

# Remove Unnecessary Columns
data <- select(data, subset = -c(id, turns, rated, created_at, last_move_at, increment_code))

# Final hold-out test set will be 10% of data
set.seed(100, sample.kind="Rounding") # if using R 3.6 or later
# set.seed(1) # if using R 3.5 or earlier
holdout_index <- createDataPartition(y = data$winner, times = 1, p = 0.1, list = FALSE)

final_holdout_test <- data[holdout_index,]
main_df <- data[-holdout_index,]
rm(results, holdout_index, data)
#########################################################

# Storing Results:
results <- data.frame(Algorithm = character(),
                      Accuracy = numeric(),
                      stringsAsFactors = FALSE)

# Accuracy Calculation Function:
calculate_accuracy <- function(predicted, observed) {
  return(mean(predicted == observed))
}

store_plot<- function(filename, plot, h = 6, w = 12) {
  res <- 300
  height <- h * res
  width <- w * res
  png(file = paste("graphs/", filename, sep = ""), height = height, width = width, res = res)
  print(plot)
  dev.off()
}



