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
data_file_1 = "../datasets/vehicle_insurance_data/motor_data14-2018.csv"
data_file_2 = "../datasets/vehicle_insurance_data/motor_data11-14lats.csv"
if(!(file.exists(data_file_1) & file.exists(data_file_2))){
  print("Please extract the contents of the following dataset to datasets/vehicle_insurance_data")
  print("https://www.kaggle.com/datasets/imtkaggleteam/vehicle-insurance-data?resource=download")
  stop("Missing dataset")
}

###################################################
# Create main and final_holdout_test sets 
# Note: this process could take a couple of minutes
###################################################

data <- rbind(read.csv(data_file_1), read.csv(data_file_2))
names(data) <- tolower(names(data))

# Preprocessing

# Date formatting:
data <- data %>%
  mutate(
    insr_begin = as.Date(insr_begin, format = "%d-%b-%y"),
    insr_end = as.Date(insr_end, format = "%d-%b-%y")
  )

# Boolean for continuous or non-continous coverage
# Check for gaps
# This takes quite some time (15-20 mins)
gaps <- data %>%
  group_by(object_id) %>%
  arrange(object_id, insr_begin) %>%
  mutate(
    next_begin_date = lead(insr_begin),
    end_date_diff = next_begin_date - insr_end
  ) %>%
  filter(end_date_diff > 1)

# Split data -----------------------------------------------------------------------------
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
rmse_df <- data.frame(Algorithm = character(),
                      RMSE = numeric(),
                      stringsAsFactors = FALSE)

# RMSE Calculation Function:
calculate_rmse <- function(predicted_ratings, actual_ratings) {
  errors <- predicted_ratings - actual_ratings
  squared_errors <- errors^2
  mean_of_squared_errors <- mean(squared_errors)
  rmse <- sqrt(mean_of_squared_errors)
  return(rmse)
}

store_plot<- function(filename, plot, h = 6, w = 12) {
  res <- 300
  height <- h * res
  width <- w * res
  png(file = paste("graphs/", filename, sep = ""), height = height, width = width, res = res)
  print(plot)
  dev.off()
}



