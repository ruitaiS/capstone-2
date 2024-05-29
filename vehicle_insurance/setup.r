###############
# Initial Setup
###############

library(tidyverse)
library(caret)
library(dplyr)
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
    start_date = as.Date(insr_begin, format = "%d-%b-%y"),
    end_date = as.Date(insr_end, format = "%d-%b-%y")
  )
data <- subset(data, select = -c(insr_begin, insr_end))

# Boolean for continuous or non-continous coverage

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

#RMSE Calculation Function:
calculate_rmse <- function(predicted_paid, actual_paid) {
  differences <- predicted_paid - actual_paid
  squared_differences <- differences^2
  mean_squared_difference <- mean(squared_differences)
  rmse <- sqrt(mean_squared_difference)
  return(rmse)
}



