df <- train_df %>%
  mutate(
    begin_date = as.Date(insr_begin, format = "%d-%b-%y"),
    end_date = as.Date(insr_end, format = "%d-%b-%y")
  )

# Calculate the difference in days
df <- df %>%
  mutate(
    date_diff = as.numeric(difftime(end_date, begin_date, units = "days"))
  )

# Check if the difference is exactly one year (365 days for non-leap years)
all_one_year <- all(df$date_diff == 365)


ggplot(df, aes(x = date_diff)) +
  geom_histogram(binwidth = 1, fill = "blue", color = "black") +
  labs(title = "Histogram of Date Differences",
       x = "Date Difference (days)",
       y = "Frequency") +
  theme_minimal()

summary <- df %>%
  group_by(date_diff) %>%
  summarize(count = n()) %>%
  arrange(date_diff)

# Not all policies cover exactly one year
# Most are 364 or 365 days, but there's clusterings elsewhere

# Check if the policy has been continuous

# Check for gaps
# This takes quite some time (15-20 mins)
gaps <- df %>%
  group_by(object_id) %>%
  arrange(object_id, begin_date) %>%
  mutate(
    next_begin_date = lead(begin_date),
    end_date_diff = next_begin_date - end_date
  ) %>%
  filter(end_date_diff > 1)

# Simplest approach would be to say if the policy has ever been discontinued
# More sophisticated, you could look at how much of the previous has it been so
