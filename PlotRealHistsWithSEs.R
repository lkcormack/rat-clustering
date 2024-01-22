# load data first has columns 'values' and 'run_label'

# 1. Create overall histogram to get bin edges
hist_info <- hist(df$values, plot = FALSE)

# 2. Create histograms for each run_label
run_labels <- unique(df$run_label)
bin_counts <- matrix(NA, nrow = length(hist_info$breaks) - 1, ncol = length(run_labels))

for (i in 1:length(run_labels)) {
  label_data <- df$values[df$run_label == run_labels[i]]
  label_hist <- hist(label_data, breaks = hist_info$breaks, plot = FALSE)
  bin_counts[, i] <- label_hist$counts
}

# 3. Calculate average counts and standard errors
avg_counts <- rowMeans(bin_counts, na.rm = TRUE)
stderr <- apply(bin_counts, 1, function(x) sd(x, na.rm = TRUE) / sqrt(length(x)))

# 4. Plotting
library(ggplot2)

# Prepare data for ggplot
plot_data <- data.frame(bin_mid = hist_info$mids, avg_counts = avg_counts, stderr = stderr)

ggplot(plot_data, aes(x = bin_mid, y = avg_counts)) +
  geom_bar(stat = "identity") +
  geom_errorbar(aes(ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
  xlab("Value") +
  ylab("Average Count") +
  ggtitle("Average Counts with Standard Error")
