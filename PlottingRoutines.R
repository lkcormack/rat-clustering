###### Plotting routines for rat clustering summary data #########
library(tidyverse)

### Load a file first! ####

title_str <- paste(max(cluster_dat$rat_num), "Rats") # number of rats for figure titles

# histograms of cluster lifetimes
# 
# make a dataframe of cluster lengths (in sec) and sizes over length
# threshold for plotting
len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
thresh_lengths_sizes <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
thresh_lengths_sizes$lengths <- (thresh_lengths_sizes$lengths)/60 # convert to seconds

# histograms of lifetimes; runs by color
clstr_len_plot <- thresh_lengths_sizes %>%
  ggplot(aes(x = lengths, color = as.factor(run_label))) +
  geom_freqpoly(bins = 30, alpha = 0.4, position = "identity") +
  ggtitle(title_str, subtitle = "lifetimes; runs by color") +
  xlab("cluster length (seconds)")
show(clstr_len_plot)

# histograms of lifetimes collapsed across run
all_clstr_len_plot <- thresh_lengths_sizes %>%
  ggplot(aes(x = lengths)) +
  geom_histogram(bins = 30, fill = "blue", alpha = 0.7) +
  ggtitle(title_str, subtitle = "lifetimes; all runs combined") +
  xlab("cluster length (seconds)")
show(all_clstr_len_plot)

# these plots are mainly for > 3 rats

# histograms of group sizes; runs by color
clstr_size_plot <- cluster_lengths_sizes %>%
  ggplot(aes(x = values, fill = as.factor(run_label))) +
  geom_histogram(bins = 30, alpha = 0.4, position ="identity") +
  ggtitle(title_str, subtitle = "cluster sizes; runs by color") +
  xlab("cluster size")
show(clstr_size_plot)

# histograms of group sizes collapsed across run
all_clstr_size_plot <- cluster_lengths_sizes %>%
  ggplot(aes(x = values, after_stat(density))) +
  geom_histogram(binwidth = 1, fill = "blue", alpha = 0.7) +
  xlim(0, 15) +
  ylim(0, 0.8) +
  ggtitle(title_str, subtitle = "cluster sizes; all runs combined") +
  xlab("cluster size")
show(all_clstr_size_plot)

p <- thresh_lengths_sizes %>% 
  ggplot(aes(x = values, y =  lengths)) + 
  geom_jitter(width = 0.2, height = 0, alpha = 0.2) +
  ggtitle(title_str, subtitle = "size vs. duration") + 
  xlim(3, 15) +
  ylim(0, 10) +
  xlab("cluster size") +
  ylab("duration (seconds)")
show(p)
