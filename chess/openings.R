# Openings created from main_df (ctrl f replace to switch it)

opener_wr <- aggregate(winner ~ opening_eco, data = main_df, FUN = mean)%>%
  setNames(c("opening_eco", "opener_wr"))

opener_count <- main_df %>%
  group_by(opening_eco) %>%
  summarize(count = n())

openers <- merge(opener_wr, opener_count, by = "opening_eco", all.x = TRUE)

# Density Plot of Opening Counts:
density_values <- density(openers$count)
store_plot("openers_count_density.png", {
  plot(density_values, main = "Density Plot of Counts for Each Opener", xlab = "Count", ylab = "Density")
  polygon(density_values, col = "lightblue", border = "black")
  abline(v = mean(openers$count), col = "red", lty = 2)
})