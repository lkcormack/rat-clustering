###### Plot real data just like boot data #########

### Load a file first! ####
### e.g. load("6RatsClusterSummary.RData")
load("3RatsClusterSummary.RData")

title_str <- paste(max(cluster_dat$rat_num), "Rats") # number of rats for figure titles
## (or make your own)

# thresholding params
min_grp_size <- 3
min_grp_len <- 10

# histograms of group sizes collapsed across run
all_clstr_size_plot <- cluster_lengths_sizes %>%
  ggplot(aes(x = values)) +
  geom_histogram(breaks = seq(0, 16), fill = "blue", alpha = 0.7) +
  ggtitle(title_str, subtitle = "cluster sizes; all runs combined") +
  xlab("cluster size")
show(all_clstr_size_plot)

# histograms of cluster lifetimes
plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > min_grp_len, ]
plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds

# histograms of lifetimes collapsed across run
all_clstr_len_plot <- plt_lengths %>%
  ggplot(aes(x = lengths)) +
  geom_histogram(breaks = seq(0, 20, 0.2), fill = "blue", alpha = 0.7) +
  ggtitle(title_str, subtitle = "lifetimes; all runs combined") +
  xlab("cluster length (seconds)")
show(all_clstr_len_plot)

