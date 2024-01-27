# hard coded number are from the output of Comp_Summary_Stats.R
# numbers to be found in the "DistributionStats.xlsx" file on Box

library(tidyverse)

compBoot = FALSE # set to add plots comparing to bootstrapped data

##### Plots of the group sizes #####
# make the tibble of group size data
sz_df <- tibble(
  nRats = c(3, 6, 9, 15),
  means = c(3, 3.23, 3.45, 3.81),
  ses = c(0, 0.012, 0.011, 0.017)
)

sz_boot_df <- tibble(
  nRats = c(3, 6, 9, 15),
  means = c(3, 3.1289, 3.2144, 3.49),
)

# plot the group size data
sz_p <- ggplot(sz_df, aes(x = nRats, y = means)) +
  geom_point(color = "blue", size = 3) +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_continuous(breaks = c(6, 9, 15)) +
  geom_smooth(method = "lm", se = FALSE) +
  xlab("Number of Rats") +
  ylab("Average Group Size") +
  ggtitle("Mean Group Size vs. # of Rats") +
  theme_bw()
show(sz_p)

# do a regression (sigh)
sz_lm <- lm(means ~ nRats, data = sz_df)
summary(sz_lm)

if(compBoot) {
  # plot size means with the bootstrapped means
  sz_p_boot <- sz_p + 
    geom_point(data = sz_boot_df, aes(x = nRats, y = means),
               shape = 15, size = 3) +
    geom_smooth(data = sz_boot_df, 
                aes(x = nRats, y = means), 
                method = "lm", se = FALSE, 
                color = "black", linetype = "dashed")
  show(sz_p_boot)
  
  # do a regression (sigh)
  sz_boot_lm <- lm(means ~ nRats, data = sz_boot_df)
}




##### Plots of the group durations #####

# make the tibble of group duration data
dur_df <- tibble(
  nRats = c(3, 6, 9, 15),
  means = c(0.66, 0.55, 0.49, 0.45),
  ses = c(0.0388, 0.015, 0.007, 0.006)
)

dur_boot_df <- tibble(
  nRats = c(3, 6, 9, 15),
  means = c(0.7366, 0.6993, 0.5036, 0.47),
)
# plot the group duration data
dur_p <- ggplot(dur_df, aes(x = nRats, y = means)) +
  geom_point(color = "blue", size = 3) +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_continuous(breaks = c(3, 6, 9, 15)) +
  xlab("Number of Rats") +
  ylab("Average Group Duration (sec)") +
  ggtitle("Mean Group Duration vs. # of Rats") +
  theme_bw()
show(dur_p)

if(compBoot) { 
# plot duration means with the bootstrapped means
dur_p_boot <- dur_p + 
  geom_point(data = dur_boot_df, aes(x = nRats, y = means))
show(dur_p_boot)
}

# plot the group duration data on a log-log scale
dur_p_log <- ggplot(dur_df, aes(x = nRats, y = means)) +
  geom_point(color = "blue", size = 3) +
  geom_errorbar(aes(ymin = means - 2*ses, ymax = means + 2*ses), width = 0.1) +
  scale_x_log10() +
  scale_y_log10() +
  geom_smooth(method = "lm", se = TRUE) +
  xlab("Number of Rats") +
  ylab("Average Group Duration (sec)") +
  ggtitle("Duration vs. # of Rats (log-log)") +
  theme_bw()
show(dur_p_log)

# do a regression (sigh)
dur_lm <- lm(log10(means) ~ log10(nRats), data = dur_df)