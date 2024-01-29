###### Plot real data and boot data overlaid #########
library(tidyverse)
library(ggplot2)
library(glue)
### Load files first! ####
## If the files are not in your working directory, you will need to 
## specify the path, or load the files "by hand" (and comment out the 
## load() lines below)

#n_rats <- max(cluster_dat$rat_num) # yes, this is hardcoded...
n_rats <- 15
type <- "Within"

### e.g. load("6RatsClusterSummary.RData")
#load("15RatsClusterSummary.RData")
load(paste0("/Users/michaelpasala/Research/Results/Cluster/", n_rats, "RatsClusterSummary.RData")) # michael's dirs

# load boot rle_data_list
#load("15RatsBootSummary.RData")
load(paste0(glue("/Users/michaelpasala/Research/Results/{type}/"), n_rats, "RatsBootSummary.RData")) # michael's dirs


### files loaded ###

# thresholding parameters
min_grp_size <- 3
min_grp_len <- 10

####### PREPARE AND ANALYZE BOOTSTRAP DATA ########

# get number of bootstrap replications
n_reps <- length(rle_data_list)

### make tibbles for bootstrapped summaries ###
rle_boot_all <- tibble()  # all the run length encoding
size_hist_boot_all <- tibble() # counts of group sizes and lengths by bin
lifetm_hist_boot_all <- tibble() # counts of group sizes and lengths by bin

############### BOOTSTRAP DATA LOOP ####################
### go through the bootstrap replicate experiments
### hardcode n_reps to 1000 or whatever if needed
# n_reps <- 1000 
for (i in 1:n_reps) {
  print(paste("On iteration", i))
  
  rle_temp <- rle_data_list[[i]] # get the ith bootstrap replicate tibble
  rle_temp <-  rle_temp[rle_temp$values > 0, ] # extract actual groups (inc 2 rats)
  
  ### check to see if we have any data to work with (mainly for n = 3 rats) ###
  # Note: could do this with nested if blocks, but 
  # I'm going to do one-at-a-time for clarity.
  
  if (nrow(rle_temp) == 0)  next # no groups this rep; on to the next
  
  # threshold for group size
  rle_temp <-  rle_temp[rle_temp$values >= min_grp_size, ] 
  if (nrow(rle_temp) == 0)  next # no groups left; on to the next
  
  # threshold for group lifetime
  rle_temp <- rle_temp[rle_temp$lengths >= min_grp_len, ]
  if (nrow(rle_temp) == 0)  next # no groups left; on to the next
  
  # convert lifetimes to seconds
  rle_temp$lengths <- rle_temp$lengths / 60
  
  # add a column for the bootstrap replicate number
  rle_temp$bootrep <- i # code the rep number
  
  ######## NOTE: I think think that maybe we should either ########
  # - make the stacked tibble as just below, and then work from that, OR
  # - proceed as we are...
  
  # make a stacked tibble of the runs with actual groups (value != 0)
  rle_boot_all <- bind_rows(rle_boot_all, rle_temp)  # all the run length encoding
  
  # compute histograms of group lifetimes and sizes with constant, identical bins
  ###### make a histogram for sizes #####
  size_hist <- hist(rle_temp$values, 
                    breaks = seq(0, 16), # go long - can truncate for plots
                    plot = FALSE
  )
  
  ###### make a histogram for lifetimes #####
  lifetime_hist <- hist(rle_temp$lengths, 
                        breaks = seq(0, 30, 0.2), # go long - can truncate for plots
                        plot = FALSE
  )
  
  # construct a temporary tibbles holding hist() outputs for this run
  # first sizes
  sz_hist_tib_temp <- tibble(size_mids = size_hist$mids,
                             size_cnts = size_hist$counts,
                             bootrep = i)
  
  # add to the tibble of all the boot reps for group sizes
  size_hist_boot_all <- bind_rows(size_hist_boot_all, sz_hist_tib_temp)
  
  # then lifetimes
  lt_hist_tib_temp <- tibble(lifetm_mids = lifetime_hist$mids,
                             lifetm_cnts = lifetime_hist$counts,
                             bootrep = i)
  
  # add to the tibble of all the boot reps
  lifetm_hist_boot_all <- bind_rows(lifetm_hist_boot_all, lt_hist_tib_temp)
  
} ### end of for loop 
############### END OF BOOTSTRAP DATA LOOP ####################


########### summarize the bootstrap results ############

## boot means and sds for SIZES
size_summary <- size_hist_boot_all %>% 
  group_by(size_mids) %>% 
  summarise(n_obs = n(),
            size_mean = mean(size_cnts),
            size_sd = sd(size_cnts))

## boot means and sds for LIFETIMES
lifetm_summary <- lifetm_hist_boot_all %>% 
  group_by(lifetm_mids) %>% 
  summarise(n_obs = n(),
            lifetm_mean = mean(lifetm_cnts),
            lifetm_sd = sd(lifetm_cnts))

save_path <- glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/")
size_file <- glue("{n_rats}_size_plot.csv")
time_file <- glue("{n_rats}_time_plot.csv")
write.csv(lifetm_summary, file = paste0(save_path, time_file), row.names = FALSE)
write.csv(size_summary, file = paste0(save_path, size_file), row.names = FALSE)

################### PLOTTING ###############
# strings for output
# title_str <- paste(n_rats, "Rats", n_reps, "Replicates") 

# # threshold for minimum group lifetime
# plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > min_grp_len, ]
# plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds

# ##### Group sizes #####
# size_overlay <- ggplot() +
#   geom_histogram(data = plt_lengths,
#                  aes(x = values),
#                  breaks = seq(0, 16), fill = "blue", alpha = 0.7) +
#   geom_bar(data = size_summary, 
#            aes(x = size_mids, y = size_mean), 
#            stat="identity") +
#   geom_errorbar(data = size_summary,
#                 aes(x = size_mids, 
#                     ymin = size_mean - 0, 
#                     ymax = size_mean + size_sd),
#                 width = 0.25  # Width of the error bars
#   ) +
#   labs(y = "Counts", x = "Group Size", title = title_str) +
#   theme_minimal()

# print(size_overlay)

# ##### Group lifetimes #####
# # threshold for minimum group lifetime

# len_overlay <- ggplot() +
#   geom_errorbar(data = lifetm_summary, 
#                 aes(x = lifetm_mids, 
#                     ymin = lifetm_mean - 0, 
#                     ymax = lifetm_mean + lifetm_sd),
#                 width = 0.25  # Width of the error bars
#   ) +
#   geom_bar(data = lifetm_summary, 
#            aes(x = lifetm_mids, y = lifetm_mean), 
#            stat="identity") +
#  # geom_histogram(data = plt_lengths, aes(x = lengths),
#  #                 breaks = seq(0, 20, 0.2), fill = "pink", alpha = 0.5) +
#   xlim(0, 6) +
#   labs(y = "Counts", x = "Group Lifetime (sec)", title = title_str) +
#   theme_minimal() 
# print(len_overlay)


##### Group sizes plot with SEM #####

title_str <- paste(n_rats, "Rats", n_reps, "Replicates") 

# threshold for minimum group lifetime
plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > min_grp_len, ]
plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds

grp_breaks <- seq(0, 16)
size_hist_info <- hist(plt_lengths$values, breaks = grp_breaks, plot = FALSE)

# Create histograms for each run_label
run_labels <- unique(plt_lengths$run_label)
bin_counts <- matrix(NA, nrow = length(size_hist_info$breaks) - 1, ncol = length(run_labels))

for (i in 1:length(run_labels)) {
  label_data <- plt_lengths$values[plt_lengths$run_label == run_labels[i]]
  label_hist <- hist(label_data, breaks = size_hist_info$breaks, plot = FALSE)
  bin_counts[, i] <- label_hist$counts
}

# Calculate average counts and standard errors
avg_counts <- rowMeans(bin_counts, na.rm = TRUE)
stderr <- apply(bin_counts, 1, function(x) sd(x, na.rm = TRUE) / sqrt(length(x)))

# Actual Plotting

# Prepare data for ggplot
size_plot_data <- data.frame(bin_mid = size_hist_info$mids, avg_counts = avg_counts, stderr = stderr)

#p <- ggplot() + 
#  geom_bar(data = plot_data, aes(x = bin_mid, y = avg_counts), stat = "identity", fill = "blue", alpha = 0.7) +
#  geom_errorbar(data = plot_data, aes(x = bin_mid, ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
#  xlab("Group Size") +
#  ylab("Average Count") +
#  ggtitle(title_str)
#show(p)

size_overlay <- ggplot() +
  geom_bar(data = size_plot_data, aes(x = bin_mid, y = avg_counts), stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(data = size_plot_data, aes(x = bin_mid, ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
  geom_bar(data = size_summary, 
           aes(x = size_mids, y = size_mean), 
           stat="identity") +
  geom_errorbar(data = size_summary,
                aes(x = size_mids, 
                    ymin = size_mean - 0, 
                    ymax = size_mean + size_sd),
                width = 0.25  # Width of the error bars
  ) +
  coord_cartesian(ylim = c(0, 220)) +
  ggtitle(title_str) +
  labs(y = "Counts", x = "Group Size", title = title_str) +
  theme_minimal()

print(size_overlay)



#### Group lifetime with SEM ####


### make group duration histogram ###
# Create overall histogram to get bin edges
dur_breaks <- seq(0, 15, length.out = 75) # why isn't this working for breaks?
dur_hist_info <- hist(plt_lengths$lengths, breaks = dur_breaks, plot = FALSE)

# Create histograms for each run_label
run_labels <- unique(plt_lengths$run_label)
bin_counts <- matrix(NA, nrow = length(dur_hist_info$breaks) - 1, ncol = length(run_labels))

for (i in 1:length(run_labels)) {
  label_data <- plt_lengths$lengths[plt_lengths$run_label == run_labels[i]]
  label_hist <- hist(label_data, breaks = dur_hist_info$breaks, plot = FALSE)
  bin_counts[, i] <- label_hist$counts
}

# Calculate average counts and standard errors
avg_counts <- rowMeans(bin_counts, na.rm = TRUE)
stderr <- apply(bin_counts, 1, function(x) sd(x, na.rm = TRUE) / sqrt(length(x)))

# Actual Plotting

# Prepare data for ggplot
lifetime_plot_data <- data.frame(bin_mid = dur_hist_info$mids, avg_counts = avg_counts, stderr = stderr)

#p <- ggplot(plot_data, aes(x = bin_mid, y = avg_counts)) +
#  geom_bar(stat = "identity", fill = "blue", alpha = 0.7) +
#  geom_errorbar(aes(ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
#  xlim(0, 6) +
#  xlab("Group Duration (sec)") +
#  ylab("Average Count") +
#  ggtitle(title_str)
#show(p)


nRats <- max(cluster_dat$rat_num) # number of rats
title_str <- paste(nRats, "Rats (error bars = ± SE)") # number of rats for figure titles



len_overlay <- ggplot() +
  geom_bar(data = lifetime_plot_data, aes(x = bin_mid, y = avg_counts), stat = "identity", fill = "blue", alpha = 0.7) +
  geom_errorbar(data = lifetime_plot_data, aes(x = bin_mid, ymin = avg_counts - stderr, ymax = avg_counts + stderr), width = 0.1) +
  geom_errorbar(data = lifetm_summary, 
                aes(x = lifetm_mids, 
                    ymin = lifetm_mean - 0, 
                    ymax = lifetm_mean + lifetm_sd),
                width = 0.25  # Width of the error bars
  ) +
  geom_bar(data = lifetm_summary, 
           aes(x = lifetm_mids, y = lifetm_mean), 
           stat="identity") +
  # geom_histogram(data = plt_lengths, aes(x = lengths),
  #                 breaks = seq(0, 20, 0.2), fill = "pink", alpha = 0.5) +
  xlim(0, 6) +
  coord_cartesian(ylim = c(0, 200)) +
  labs(y = "Mean Counts", x = "Group Lifetime (sec)", title = title_str) +
  theme_minimal() 
print(len_overlay)



##### Group lifetimes plot with SEM #####


print(paste("boot dur mean = ", mean(rle_boot_all$lengths)))
print(paste("boot sz mean =", mean(rle_boot_all$values)))

print(paste("boot dur sd = ", sd(rle_boot_all$lengths)))
print(paste("boot sz sd =", sd(rle_boot_all$values)))

print(paste("boot dur skew = ", skewness(rle_boot_all$lengths)))
print(paste("boot sz skew =", skewness(rle_boot_all$values)))
