# hard coded number are from the output of Comp_Summary_Stats.R
# numbers to be found in the "DistributionStats.xlsx" file on Box

library(tidyverse)

# make the tibble of group size data
sz_df <- tibble(
  nRats = c(6, 9, 15),
  means = c(3.23, 3.45, 3.81),
  ses = c(0.012, 0.011, 0.017)
)

# plot the group size data
sz_p <- ggplot(sz_df, aes(x = nRats, y = means)) +
  geom_point() +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_continuous(breaks = c(6, 9, 15)) +
  geom_smooth(method = "lm", se = FALSE) +
  xlab("Number of Rats") +
  ylab("Average Group Size") +
  ggtitle("Mean Group Size vs. n Rats") +
  theme_bw()
show(sz_p)

# make the tibble of group duration data
dur_df <- tibble(
  nRats = c(3, 6, 9, 15),
  means = c(0.66, 0.55, 0.49, 0.45),
  ses = c(0.0388, 0.015, 0.007, 0.006)
)

# plot the group duration data
dur_p <- ggplot(dur_df, aes(x = nRats, y = means)) +
  geom_point() +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_continuous(breaks = c(3, 6, 9, 15)) +
  xlab("Number of Rats") +
  ylab("Average Group Duration (sec)") +
  ggtitle("Mean Group Duration vs. n Rats") +
  theme_bw()
show(dur_p)

# plot the group duration data on a log-log scale
dur_p_log <- ggplot(dur_df, aes(x = nRats, y = means)) +
  geom_point() +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_log10() +
  scale_y_log10() +
  geom_smooth(method = "lm", se = TRUE) +
  xlab("Number of Rats") +
  ylab("Average Group Duration (sec)") +
  ggtitle("Duration vs. n Rats (log-log)") +
  theme_bw()
show(dur_p_log)