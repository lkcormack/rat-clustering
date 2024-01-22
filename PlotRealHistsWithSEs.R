# load xRatsClusterSummary.RData file 

library(ggplot2)

# then...
nRats <- max(cluster_dat$rat_num) # number of rats
title_str <- paste(nRats, "Rats (error bars = ± SE)") # number of rats for figure titles

# make a dataframe of cluster lengths (in sec) and sizes over length
# threshold for plotting
len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
thresh_lengths_sizes <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
thresh_lengths_sizes$lengths <- (thresh_lengths_sizes$lengths)/60 # convert to seconds
df <- thresh_lengths_sizes # rename for convenience

### make group size histogram ###
# Create overall histogram to get bin edges
grp_breaks <- seq(0, 15, by = 1)
size_hist_info <- hist(df$values, breaks = grp_breaks, plot = FALSE)

# Create histograms for each run_label
run_labels <- unique(df$run_label)
bin_counts <- matrix(NA, nrow = length(size_hist_info$breaks) - 1, ncol = length(run_labels))

for (i in 1:length(run_labels)) {
  label_data <- df$values[df$run_label == run_labels[i]]
  label_hist <- hist(label_data, breaks = size_hist_info$breaks, plot = FALSE)
  bin_counts[, i] <- label_hist$counts
}

# Calculate average counts and standard errors
avg_counts <- rowMeans(bin_counts, na.rm = TRUE)
stderr <- apply(bin_counts, 1, function(x) sd(x, na.rm = TRUE) / sqrt(length(x)))

# Actual Plotting

# Prepare data for ggplot
plot_data <- data.frame(bin_mid = size_hist_info$mids, avg_counts = avg_counts, stderr = stderr)

p <- ggplot(plot_data, aes(x = bin_mid, y = avg_counts)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(aes(ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
  xlab("Group Size") +
  ylab("Average Count") +
  ggtitle(title_str)
show(p)

### make group duration histogram ###
# Create overall histogram to get bin edges
dur_breaks <- seq(0, 6, length.out = 30) # why isn't this working for breaks?
dur_hist_info <- hist(df$lengths, breaks = 30, plot = FALSE)

# Create histograms for each run_label
run_labels <- unique(df$run_label)
bin_counts <- matrix(NA, nrow = length(dur_hist_info$breaks) - 1, ncol = length(run_labels))

for (i in 1:length(run_labels)) {
  label_data <- df$lengths[df$run_label == run_labels[i]]
  label_hist <- hist(label_data, breaks = dur_hist_info$breaks, plot = FALSE)
  bin_counts[, i] <- label_hist$counts
}

# Calculate average counts and standard errors
avg_counts <- rowMeans(bin_counts, na.rm = TRUE)
stderr <- apply(bin_counts, 1, function(x) sd(x, na.rm = TRUE) / sqrt(length(x)))

# Actual Plotting

# Prepare data for ggplot
plot_data <- data.frame(bin_mid = dur_hist_info$mids, avg_counts = avg_counts, stderr = stderr)

p <- ggplot(plot_data, aes(x = bin_mid, y = avg_counts)) +
  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(aes(ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
  xlab("Group Duration (sec)") +
  ylab("Average Count") +
  ggtitle(title_str)
show(p)

