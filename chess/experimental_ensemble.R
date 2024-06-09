# Accuracy of Guessing higher rated, performed on subsets
# Subsetting by MINIMUM rating difference
# All games with rating difference larger than X

# As X increases:
# the dataset becomes more restricted, because there are fewer games with larger rating differences
# The accuracy increases, because a larger rating advantage means more likely to win
# We can pick as high of an accuracy of we want,
# but the algorithm will only be applicable to a correspondingly small subset of the data

# Note that once the accuracy goes to 1 it never goes back down:
# We're essentially saying "For all games of this rating difference or greater,
# the outcome of every game can be predicted by guessing the higher rated player"
# Increasing the rating cutoff past here is unnecessary.

# As the green line in the second graph shows, the increase in accuracy never outstrips the decrease in dataset size.
# The product of Accuracy * Dataset size shows the proportion of the full dataset we're able to make correct predictions on
# Eg. A cutoff that gives 100% accurate predictions but is only applicable to 50% of the dataset
# is less valuable than a cutoff that gives 60% accurate predictions, but is applicable to the full dataset.

# However, the green line is slightly misleading, because it only shows the proportion of correct predictions given by THIS algorithm
# Eg. It assumes that the algorithm we use for the rest of the data will always get the prediction WRONG.
# It is a lower bound - we already know that even if we always guess white for the remaining data,
# we should at least get over half of the remaining data correct.

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

rm(cutoff, accuracy, filtered, predicted)

plot <- ggplot(tuning_results, aes(x = cutoff)) +
  #geom_point(aes(y = accuracy, color = "Accuracy")) +
  geom_line(aes(y = accuracy, color = "Accuracy"), size=1.5) +
  #geom_point(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Percentage")) +  # Product plot
  geom_line(aes(y = accuracy * (dataset_size/nrow(main_df)), color = "Accuracy * Percentage"), size=1.5) +
  #geom_point(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset")) +  # Dataset percentage plot
  geom_line(aes(y = dataset_size/nrow(main_df), color = "Percentage of Dataset"), size=1.5) +
  scale_color_manual(values = c("Accuracy" = "blue", "Percentage of Dataset" = "red", "Accuracy * Percentage" = "green"),
                     breaks = c("Accuracy", "Percentage of Dataset", "Accuracy * Percentage")) +
  #scale_color_manual(values = c("Accuracy" = "blue", "Percentage of Dataset" = "red"), guide = guide_legend(title = "")) +
  labs(x = "Minimum Rating Difference", y = "") +
  ggtitle("Minimum Rating Difference Subsetting") +
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