###### Compute summary stats for rat clustering summary data #########

library(tidyverse)
library(e1071) # for skewness

### Load a file first! ####
# load yer file here...

# then...
nRats <- max(cluster_dat$rat_num) # number of rats
title_str <- paste(nRats, "Rats") # number of rats for figure titles

# make a dataframe of cluster lengths (in sec) and sizes over length
# threshold for plotting
len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
thresh_lengths_sizes <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
thresh_lengths_sizes$lengths <- (thresh_lengths_sizes$lengths)/60 # convert to seconds

# compute overall summary statistics

# length summary stats
mean_length <- mean(thresh_lengths_sizes$lengths)
std_length <- sd(thresh_lengths_sizes$lengths)
skew_length <- skewness(thresh_lengths_sizes$lengths)

# length summary stats by run
length_stats <- thresh_lengths_sizes %>%
  group_by(run_label) %>%
  summarize(mean_length = mean(lengths),
            std_length = sd(lengths),
            st_error = std_length/sqrt(n()),
            skew_length = skewness(lengths))

# empirical standard error of the mean
emp_st_error_length <- sd(length_stats$mean_length)/sqrt(nrow(length_stats))

# size summary stats
if (nRats > 3) {
  mean_size <- mean(thresh_lengths_sizes$values)
  std_size <- sd(thresh_lengths_sizes$values)
  skew_size <- skewness(thresh_lengths_sizes$values)
  
  # size summary stats by run
  size_stats <- thresh_lengths_sizes %>%
    group_by(run_label) %>%
    summarize(mean_size = mean(values),
              std_size = sd(values),
              st_error = std_size/sqrt(n()),
              skew_size = skewness(values))
  
  # empirical standard error of the mean
  emp_st_error_size <- sd(size_stats$mean_size)/sqrt(nrow(size_stats))
}

# histograms of lifetimes collapsed across run
all_clstr_len_plot <- thresh_lengths_sizes %>%
  ggplot(aes(x = lengths)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7) +
  ggtitle(title_str, subtitle = "lifetimes; all runs combined") +
  xlab("cluster length (seconds)")
show(all_clstr_len_plot)

# histograms of group sizes collapsed across run
if (nRats > 3) {
  all_clstr_size_plot <- cluster_lengths_sizes %>%
    ggplot(aes(x = values, after_stat(density))) +
    geom_histogram(binwidth = 1, fill = "blue", alpha = 0.7) +
    xlim(0, 15) +
    ylim(0, 0.8) +
    ggtitle(title_str, subtitle = "cluster sizes; all runs combined") +
    xlab("cluster size")
  show(all_clstr_size_plot)
}

