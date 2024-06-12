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

#################################################################################
# players_setup.R
#################################################################################

# Unique Players Dataframe:
players <- data.frame(player_id = unique(c(main_df$white_id, main_df$black_id)))

# Player's Game Statistics
white_wins <- main_df %>%
  filter(winner == 1) %>%
  group_by(white_id) %>%
  summarise(white_wins = n())

white_games <- main_df %>%
  group_by(white_id) %>%
  summarise(white_games = n())

black_wins <- main_df %>%
  filter(winner == 1) %>%
  group_by(black_id) %>%
  summarise(black_wins = n())

black_games <- main_df %>%
  group_by(black_id) %>%
  summarise(black_games = n())

players <- merge(players, white_wins, by.x = "player_id", by.y = "white_id", all.x = TRUE)
players <- merge(players, black_wins, by.x = "player_id", by.y = "black_id", all.x = TRUE)
players <- merge(players, white_games, by.x = "player_id", by.y = "white_id", all.x = TRUE)
players <- merge(players, black_games, by.x = "player_id", by.y = "black_id", all.x = TRUE)
players$total_games <- coalesce(players$white_games, 0) + coalesce(players$black_games, 0)

# Convert NA wins to 0 if they've played on that side
# Distinguish from 0 wins to never played
players$white_wins[!is.na(players$white_games) & is.na(players$white_wins)] <- 0
players$black_wins[!is.na(players$black_games) & is.na(players$black_wins)] <- 0

players$white_wr <- players$white_wins/players$white_games
players$black_wr <- players$black_wins/players$black_games
players$overall_wr <- (coalesce(players$white_wins, 0) + coalesce(players$black_wins, 0))/(coalesce(players$white_games, 0) + coalesce(players$black_games, 0))

rm(white_wins, white_games, black_wins, black_games)

#################################################################################
# graphs.R
#################################################################################

# White's WR Vs. Average Rating of the two players:
plot_df <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2) %>%
  select(avg_rating, winner) %>%
  group_by(avg_rating) %>%
  summarize(white_wr = mean(winner, na.rm = TRUE))

plot <- ggplot(plot_df, aes(x = avg_rating, y = white_wr)) +
  geom_point() +
  labs(title = "White Win Rate by Game Rating",
       x = "Game Rating",
       y = "White's Win Rate") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("white_wr_by_game_rating.png", plot)
rm(plot, plot_df)

#################################################################################
# ratings_graphs.R
#################################################################################

# White's WR Vs. Average Rating of the two players:
plot_df <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2) %>%
  select(avg_rating, winner) %>%
  group_by(avg_rating) %>%
  summarize(white_wr = mean(winner, na.rm = TRUE))

plot <- ggplot(plot_df, aes(x = avg_rating, y = white_wr)) +
  geom_point() +
  #geom_line() +
  labs(title = "White Win Rate by Game Rating",
       x = "Game Rating",
       y = "White's Win Rate") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("white_wr_by_game_rating.png", plot)

# White vs. Black Rating
plot <- ggplot(main_df, aes(x = white_rating, y = black_rating, color = factor(winner))) +
  geom_point() +
  scale_color_manual(values = c("blue", "red"), labels = c("Black", "White")) +
  labs(title = "White Vs. Black Ratings ",
       x = "White's Rating",
       y = "Black's Rating",
       color = "Winner") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", size=1.5, color = "green") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("white_vs_black_ratings.png", plot, h = 6, w=6)
#rm(plot)

# White's WR vs. Rating Advantage
plot_df <- main_df %>%
  mutate(rating_diff = white_rating - black_rating) %>%
  select(rating_diff, winner) %>%
  group_by(rating_diff) %>%
  mutate(count = n()) %>%
  ungroup() %>%
  filter(count >= 5) %>% # Cleans up noise at edges and increments
  aggregate(winner ~ rating_diff, data = ., FUN = mean) %>%
  setNames(c("rating_diff", "wr"))


plot <- ggplot(plot_df, aes(x = rating_diff, y = wr)) +
  geom_point() +
  labs(title = "Rating Difference Vs. Win Rate",
       x = "White Minus Black Rating Difference",
       y = "White's Win Rate") +
  geom_smooth(method = "lm", se = FALSE, color = "red")+
  ylim(-0, 1) +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("wr_by_rating_diff_filtered_regline.png", plot, h = 6, w=6)
rm(plot, plot_df)

#################################################################################
# openings_graphs.R
#################################################################################

opener_wr <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean)%>%
  setNames(c("opening_eco", "white_wr"))

opener_wins <- aggregate(winner ~ opening_eco, data = main_df, FUN = sum)%>%
  setNames(c("opening_eco", "white_wins"))

opener_count <- main_df %>%
  group_by(opening_eco) %>%
  summarize(count = n())

openers <- merge(opener_wr, opener_count, by = "opening_eco", all.x = TRUE) %>%
  merge(opener_wins, by = "opening_eco", all.x = TRUE)
openers$black_wins <- openers$count - openers$white_wins
openers <- openers[order(openers$count, decreasing = TRUE), ]
openers$opening_eco <- factor(openers$opening_eco, levels = unique(openers$opening_eco)) # Needs set after sums
rm(opener_wr, opener_count, opener_wins)

# Most Common Openers
#head(openers[order(openers$count, decreasing=TRUE), ]) %>%
#print(row.names=FALSE)

# Density Plot of Opening Counts:
density_values <- density(openers$count)
plot <- {plot(density_values, main = "Density Plot of Instances of Each Opener", xlab = "Count", ylab = "Density")
  polygon(density_values, col = "lightblue", border = "black")
}
print(plot)
#store_plot("openers_count_density.png", plot)

# Bar Plot of Opener Winners
plot_df <- openers[, c("opening_eco", "white_wins", "black_wins")] %>% pivot_longer(cols = -opening_eco,names_to = "Winner")
plot_df <- plot_df[1:50,]

plot <- ggplot(plot_df,aes(x=opening_eco, y = value,fill= Winner)) + 
  geom_col(position="dodge") + 
  scale_fill_manual(values = c("white_wins" = "lightgray", "black_wins" = "black"), guide="none") +
  scale_y_continuous(sec.axis = sec_axis(~ . ))+
  labs(x= "Opening ECO Code", y="Number of Wins") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("wins_by_opener_top_25.png", plot)

rm(openers, density_values, plot, plot_df)

#################################################################################
# simple_algorithms.R
#################################################################################

# Random Guess
set.seed(1)
predicted <- sample(0:1, length(main_df$winner), replace = TRUE)
results <- rbind(results, data.frame(
  Algorithm = "Random Guess",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Predict White to Win Every Match
predicted <- rep(1, length(main_df$winner))
results <- rbind(results, data.frame(
  Algorithm = "White Always Wins",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Predict Higher Rated Player Wins:
predicted <- ifelse(main_df$white_rating >= main_df$black_rating, 1, 0)
results <- rbind(results, data.frame(
  Algorithm = "Higher Rated Wins",
  Accuracy = calculate_accuracy(
    predicted,
    main_df$winner)))

# Store into Environment For Later
white_always_wins <- calculate_accuracy(
  rep(1, nrow(main_df)),
  main_df$winner)
higher_rated_wins <- calculate_accuracy(
  ifelse(main_df$white_rating >= main_df$black_rating, 1, 0),
  main_df$winner)

# Cleanup
rm(predicted, predictions)

#################################################################################
# minimum_rating_difference.R
#################################################################################

# Subsetting by MINIMUM rating difference
# Predict higher rated player wins
# only on games with rating difference larger than X-axis value

tuning_results <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in 1:max(abs(main_df$white_rating - main_df$black_rating))-1) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) >= cutoff)
  predicted <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predicted, filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
  if (accuracy == 1) {
    # Any rating difference greater than the current cutoff will yield perfect results 
    # Increasing cutoff past here will only decrease dataset size
    break
  }
}

# Save Cutoff for later graphs
cutoff_limit <- max(tuning_results$cutoff)
rm(cutoff, accuracy, filtered, predicted)

plot <- ggplot(tuning_results, aes(x = cutoff)) +
  geom_line(aes(y = accuracy, color = "Accuracy"), size=1.5) +
  geom_line(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Percentage"), size=1.5) +
  geom_line(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset"), size=1.5) +
  scale_color_manual(values = c("Accuracy" = "blue", "Percentage of Dataset" = "red", "Accuracy * Percentage" = "green"),
                     breaks = c("Accuracy", "Percentage of Dataset", "Accuracy * Percentage")) +
  labs(x = "Minimum Rating Advantage", y = "") +
  ggtitle("Minimum Rating Advantage Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting1.png", plot)

rm(plot, tuning_results)

#################################################################################
# maximum_rating_difference.R
#################################################################################

# Subsetting by MAXIMUM rating difference
# Predict higher rated player wins
# only on games with rating difference smaller than X-axis value

tuning_results <- data.frame(accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Tune Difference Cutoff By Checking Strength in Cutoff Group
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    # Cutoff now defines MAXIMUM rating diff, not minimum
    filter(abs(white_rating - black_rating) <= cutoff)
  predictions <- ifelse(filtered$white_rating >= filtered$black_rating, 1, 0)
  accuracy <- calculate_accuracy(predictions, filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    accuracy = accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# First cutoff where higher player wins gives lower accuracy than guessing white for all
threshold <- max(tuning_results[which(tuning_results$accuracy < white_always_wins),]$cutoff)
plot <- ggplot(tuning_results, aes(x = cutoff)) +
  scale_x_reverse() +
  geom_rect(aes(xmin = -Inf, xmax = threshold, ymin = -Inf, ymax = Inf), fill = "gray", alpha = 0.2) +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  geom_line(aes(y = accuracy, color = "Predict Higher Rated Wins"), size = 1.5) +
  scale_color_manual(values = c("Predict Higher Rated Wins" = "blue"), guide = "none") +
  labs(x = "Maximum Rating Advantage", y = "") +
  ggtitle("Max Rating Advantage Subsetting") +
  theme(legend.position = "right")+
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting2.png", plot)



# Additional Terminal Outputs:
#Print First cutoff where higher player wins gives lower accuracy than guessing white for all
head(tuning_results[which(tuning_results$accuracy < white_always_wins),], 1)

# Cleanup
rm(threshold, predictions, tuning_results)

#################################################################################
# note.R
#################################################################################

# Showing the proportion of white wins holds constant
# for any set of games (assuming skill is equally distributed among white and black players)

tuning_results <- data.frame(guess_white_accuracy = numeric(),
                             dataset_size = numeric(),
                             cutoff = numeric(),
                             stringsAsFactors = FALSE)

# Plot accuracy of "white wins" against the same cutoffs as "higher rated wins"
for (cutoff in seq(from = max(abs(main_df$white_rating - main_df$black_rating)), to = 0, by = -1)) {
  filtered <- main_df %>%
    filter(abs(white_rating - black_rating) <= cutoff)
  guess_white_accuracy <- calculate_accuracy(rep(1, nrow(filtered)), filtered$winner)
  tuning_results <- rbind(tuning_results, data.frame(
    guess_white_accuracy = guess_white_accuracy,
    dataset_size = nrow(filtered),
    cutoff = cutoff))
}

rm(cutoff, accuracy, filtered, predicted)

# Subsetting has negligible effect on white's win rate:
plot <- ggplot(tuning_results, aes(x = cutoff)) +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_line(aes(y = guess_white_accuracy, color = "Predict White Wins")) +
  scale_color_manual(values = c("Predict White Wins" = "red"), guide = "none") +
  scale_x_reverse() +
  labs(x = "Maximum Rating Advantage", y = "") +
  ggtitle("Max Rating Advantage Subsetting") +
  theme_minimal()+
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting2-white_wins.png", plot)

# Cleanup
rm(guess_white_accuracy, plot, tuning_results)

#################################################################################
# hybrid_model.R
#################################################################################

# Basic Hybrid Model
# Switch to white_always_wins

# Store Ratings Data Used Throughout Section 6
ratings <- main_df %>% 
  mutate(diff = abs(white_rating - black_rating)) %>%
  select(diff, white_rating, black_rating, moves, opening_eco)
# ------------------------------------------------------------------

tuning_results_0 <- data.frame(accuracy = numeric(),
                               cutoff = numeric(),
                               stringsAsFactors = FALSE)

for (cutoff in 0:cutoff_limit) { # Maintain previous Scale to plot all hybrid models together
  #for (cutoff in 0:60) { # Zoomed
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return(1)
    }
  })
  
  accuracy <- calculate_accuracy(predicted, main_df$winner)
  tuning_results_0 <- rbind(tuning_results_0, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_0, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple", size = 1.5) + # remove size = 1.5 if zoomed
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") + # Comment out for zoomed
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Basic Hybrid Model") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting3.png", plot)

# Cleanup
rm(plot, predicted)

#################################################################################
# hybrid_bin_winner.R
#################################################################################

# Hybrid Model Improvement 1
# Switch to Rating Bin Winner

summary_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = floor(avg_rating / 100) * 100,
  ) %>%
  group_by(rating_bin) %>%
  summarize(bin_mean = mean(winner),
            bin_count = n())

bin_winner <- function(white_rating, black_rating){
  avg_rating <- (white_rating + black_rating) / 2
  rating_bin <- floor(avg_rating / 100)*100
  
  match_index <- which(summary_data$rating_bin == rating_bin)
  
  if (length(match_index)>0){
    return (ifelse(summary_data[match_index,]$bin_mean >= 0.5, 1, 0))
  }else{
    return (as.integer(1))
  }
}

#-------------------------------------------------------------------------------

tuning_results_1 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
)

for (cutoff in 0:cutoff_limit) {
  print(cutoff)
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (bin_winner(row[['white_rating']], row[['black_rating']]))
    }
  })
  accuracy <- calculate_accuracy(unlist(predicted), main_df$winner)
  tuning_results_1 <- rbind(tuning_results_1, data.frame(
    accuracy = accuracy,
    cutoff = cutoff))
}

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_1, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple") +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Hybrid Model 1") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)

# Cleanup
rm(summary_data, bin_winner, plot, predicted)

#################################################################################
# hybrid_eco_winner.R
#################################################################################

# Hybrid Model Improvement 2
# Switch to ECO group winner

aggregated_results <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean, na.rm = TRUE)
eco_winner <- function(opening_eco) {
  index <- match(opening_eco, aggregated_results$opening_eco)
  if (is.na(index)) {
    return(1)
  } else {
    mean_wr <- aggregated_results$winner[index]
    return(ifelse(mean_wr >= 0.5, 1, 0))
  }
}

#-------------------------------------------------------------------------------
tuning_results_2 <- data.frame(accuracy = numeric(),
                               cutoff = numeric()
)
for (cutoff in 0:cutoff_limit) { # Maintain Previous Scale
  print(cutoff)
  predicted <- apply(ratings, 1, function(row){
    if (row[['diff']] >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (eco_winner(row[['opening_eco']]))
    }
  })
  accuracy <- calculate_accuracy(unlist(predicted), main_df$winner)
  tuning_results_2 <- rbind(tuning_results_2, data.frame(
    accuracy = accuracy,
    cutoff = cutoff
  ))
}

rm(accuracy, cutoff)

plot <- ggplot(tuning_results_2, aes(x = cutoff, y = accuracy)) +
  geom_line(color = "purple") +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy") +
  ggtitle("Hybrid Model 2") +
  scale_x_reverse() +
  theme_minimal()+
  theme(
    text = element_text(size = unit(2, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting_improved.png", plot)

# Cleanup
rm(plot, predicted, aggregated_results, eco_winner)

#################################################################################
# hybrid_model_single_chart.R
#################################################################################

# Combine all tuning_results dataframes into a single chart

combined_results <- rbind(
  transform(tuning_results_0, source = "white_always_wins"),
  transform(tuning_results_1, source = "rating_bin_winner"),
  transform(tuning_results_2, source = "eco_winner")
)

# Plotting with combined data
plot <- ggplot(combined_results, aes(x = cutoff, y = accuracy, color = source)) +
  geom_line() +
  geom_hline(yintercept = white_always_wins, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins, linetype = "dashed", color = "blue") +
  labs(x = "Cutoff", y = "Accuracy", color = "Source") +
  ggtitle("Hybrid Models Combined") +
  scale_x_reverse() +
  theme_minimal() +
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("cutoff_subsetting_combined.png", plot)

rm(plot, combined_results)

# Determining Optimal Value to Set the Cutoff
best_cutoffs <- head(tuning_results_2[order(tuning_results_2$accuracy, decreasing = TRUE), ])

#################################################################################
# final_results.R
#################################################################################

summary_data <- main_df %>%
  mutate(avg_rating = (white_rating + black_rating) / 2,
         rating_bin = floor(avg_rating / 100) * 100,
  ) %>%
  group_by(rating_bin) %>%
  summarize(bin_mean = mean(winner),
            bin_count = n())

bin_winner <- function(white_rating, black_rating){
  avg_rating <- (white_rating + black_rating) / 2
  rating_bin <- floor(avg_rating / 100)*100
  
  match_index <- which(summary_data$rating_bin == rating_bin)
  
  if (length(match_index)>0){
    return (ifelse(summary_data[match_index,]$bin_mean >= 0.5, 1, 0))
  }else{
    return (as.integer(1))
  }
}

# ----------
aggregated_results <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean, na.rm = TRUE)
eco_winner <- function(opening_eco) {
  index <- match(opening_eco, aggregated_results$opening_eco)
  if (is.na(index)) {
    return (1)
  } else {
    mean_wr <- aggregated_results$winner[index]
    return (ifelse(mean_wr >= 0.5, 1, 0))
  }
}

# ----------
# Static Models
white_always_wins_accuracy <- calculate_accuracy(rep(1, nrow(final_holdout_test)), final_holdout_test$winner)

higher_rated_wins_accuracy <- calculate_accuracy(
  ifelse(final_holdout_test$white_rating >= final_holdout_test$black_rating, 1, 0),
  final_holdout_test$winner)

# Hybrid Models
threshold <- (69+52)/2
white_wins_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (1)
  }
}), final_holdout_test$winner)

rating_bin_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (bin_winner(row[['white_rating']], row[['black_rating']]))
  }
}), final_holdout_test$winner)

eco_winner_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
  if (abs(row[['white_rating']] - row[['black_rating']]) >= threshold) {
    return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
  } else {
    return (eco_winner(row[['opening_eco']]))
  }
}), final_holdout_test$winner)

# Store Results

algorithm_names <- c("White Wins Accuracy",
                     "Higher Rated Wins Accuracy",
                     "White Wins Hybrid",
                     "Rating Bin Hybrid",
                     "ECO Winner Hybrid")
accuracies <- c(white_always_wins_accuracy, higher_rated_wins_accuracy, white_wins_hybrid, rating_bin_hybrid, eco_winner_hybrid)

# Create the data frame
results <- data.frame(Algorithm = algorithm_names, Accuracy = accuracies)


#-------
results_final <- data.frame(accuracy = numeric(),
                            cutoff = numeric(),
                            source = character()
)

for (cutoff in 0:cutoff_limit) {
  print(cutoff)
  
  white_wins_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (1)
    }
  }), final_holdout_test$winner)
  
  rating_bin_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (bin_winner(row[['white_rating']], row[['black_rating']]))
    }
  }), final_holdout_test$winner)
  
  eco_winner_hybrid <- calculate_accuracy(apply(final_holdout_test, 1, function(row){
    if (abs(row[['white_rating']] - row[['black_rating']]) >= cutoff) {
      return(ifelse(row[['white_rating']] >= row[['black_rating']], 1, 0))
    } else {
      return (eco_winner(row[['opening_eco']]))
    }
  }), final_holdout_test$winner)
  
  results_final <- rbind(results_final, data.frame(
    accuracy = white_wins_hybrid,
    cutoff = cutoff,
    source = "White Wins Hybrid"))
  results_final <- rbind(results_final, data.frame(
    accuracy = rating_bin_hybrid,
    cutoff = cutoff,
    source = "Rating Bin Hybrid"))
  results_final <- rbind(results_final, data.frame(
    accuracy = eco_winner_hybrid,
    cutoff = cutoff,
    source = "Eco Winner Hybrid"))
}

rm(accuracy, cutoff)

plot <- ggplot(results_final, aes(x = cutoff, y = accuracy, color = source)) +
  geom_line() +
  geom_hline(yintercept = white_always_wins_accuracy, linetype = "dashed", color = "red") +
  geom_hline(yintercept = higher_rated_wins_accuracy, linetype = "dashed", color = "blue") +
  geom_vline(xintercept = threshold, linetype = "dashed") +
  labs(x = "Cutoff", y = "Accuracy", color = "Source") +
  ggtitle("Hybrid Models Combined") +
  scale_x_reverse() +
  theme_minimal() +
  theme(
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )

print(plot)
#store_plot("final_hybrid_2.png", plot)
