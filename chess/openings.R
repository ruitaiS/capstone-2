# Openings created from main_df (ctrl f replace to switch it)

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
openers$opening_eco <- factor(openers$opening_eco, levels = unique(openers$opening_eco))
openers <- openers[order(openers$count, decreasing = TRUE), ]
rm(opener_wr, opener_count, opener_wins)

# Most Common Openers
head(openers[order(openers$count, decreasing=TRUE), ]) %>%
  print(row.names=FALSE)

# Density Plot of Opening Counts:
density_values <- density(openers$count)
plot <- {plot(density_values, main = "Density Plot of Instances of Each Opener", xlab = "Count", ylab = "Density")
  polygon(density_values, col = "lightblue", border = "black")
}
store_plot("openers_count_density.png", plot)

# Bar Plot of Opener Winners
plot_df <- openers[, c("opening_eco", "white_wins", "black_wins")] %>% pivot_longer(cols = -opening_eco,names_to = "Winner")
plot_df1 <- plot_df[1:50,]
plot_df2 <- plot_df[51:100,]
plot_df3 <- plot_df[101:150,]
plot_df4 <- plot_df[151:200,]
plot_df5 <- plot_df[201:250,]
plot_df6 <- plot_df[251:300,]
plot_df7 <- plot_df[301:350,]

plot <- ggplot(plot_df1,aes(x=opening_eco, y = value,fill= Winner)) + 
  geom_col(position="dodge") + 
  scale_fill_manual(values = c("white_wins" = "lightgray", "black_wins" = "black")) +
  scale_y_continuous(sec.axis = sec_axis(~ . , name = "White Wins"))+
  labs(y="Black Wins") +
  theme_minimal()+
  theme(
    #plot.background = element_rect(fill = "lightgray"),
    text = element_text(size = unit(10, "mm")),          # General text size
    plot.title = element_text(size = unit(20, "mm")),    # Title text size
    axis.title = element_text(size = unit(15, "mm")),    # Axis titles text size
    axis.text = element_text(size = unit(10, "mm"))      # Axis text size
  )

store_plot("wins_by_opener_top_25.png", plot)