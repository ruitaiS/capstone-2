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
#  print(row.names=FALSE)

# Density Plot of Opening Counts:
density_values <- density(openers$count)
plot <- {plot(density_values, main = "Density Plot of Instances of Each Opener", xlab = "Count", ylab = "Density")
  polygon(density_values, col = "lightblue", border = "black")
}
store_plot("openers_count_density.png", plot)

# Bar Plot of Opener Winners -----------------------------------------------------------------------
plot_df <- openers[, c("opening_eco", "white_wins", "black_wins")] %>% pivot_longer(cols = -opening_eco,names_to = "Winner")
plot_df <- plot_df[1:50,]

plot <- ggplot(plot_df,aes(x=opening_eco, y = value,fill= Winner)) + 
  geom_col(position="dodge") + 
  scale_fill_manual(values = c("white_wins" = "lightgray", "black_wins" = "black"), guide="none") +
  scale_y_continuous(sec.axis = sec_axis(~ . ))+
  labs(x= "Opening ECO Code", y="Number of Wins") +
  theme_minimal()+
  theme(
    #plot.background = element_rect(fill = "lightgray"),
    text = element_text(size = unit(10, "mm")),
    plot.title = element_text(size = unit(20, "mm")),
    axis.title = element_text(size = unit(15, "mm")),
    axis.text = element_text(size = unit(10, "mm"))
  )
print(plot)
#store_plot("wins_by_opener_top_25.png", plot)

rm(openers, density_values, plot, plot_df)