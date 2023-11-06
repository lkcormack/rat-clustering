# summarize the combined bootsrapped data

library(tidyverse)

# load the file...
# load it by hand for now

# group by bootstrap replicate
grouped_boot_data <- rle_boot_all %>% group_by(bootrep)

# make a tibble of the histograms
histograms <- grouped_boot_data %>%
  mutate(value_hist = list(hist(values,
                                breaks = seq(0, 16),
                                plot = FALSE)),
         length_hist = list(hist(lengths,
                                 breaks = seq(0, 20, 0.2),
                                 plot = FALSE)))

# Group the data by "bootstrap_replicate" and bin for sizes
size_result <- histograms %>%
  unnest(value_hist) %>%
  group_by(bootstrap_replicate, bin = value_hist$mids) %>%
  summarize(
    mean_value = mean(value_hist$counts),
    sd_value = sd(value_hist$counts)
  )

# Create a bar graph with error bars for sizes
ggplot(size_result, aes(x = bin, y = mean_value, fill = as.factor(bootstrap_replicate))) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_errorbar(
    aes(ymin = mean_value - sd_value, ymax = mean_value + sd_value),
    width = 0.2,
    position = position_dodge(width = 0.9)
  ) +
  labs(x = "Bin", y = "Mean Value", fill = "Bootstrap Replicate") +
  ggtitle("Mean Values with Standard Deviation Error Bars by Bin")



