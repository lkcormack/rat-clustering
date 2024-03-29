# Analyze bootstrapping RLE results
library(tidyverse)

# load rle_data_list
load("15RatsBootSummary.RData")
n_rats <- 15 # yes, this is hardcoded...

# thresholding params
min_grp_size <- 3
min_grp_len <- 10

# get number of bootstrap replications
n_reps <- length(rle_data_list)

# strings for output
title_str <- paste(n_rats, "Rats", n_reps, "Replicates") 

# storage
rle_boot_all <- tibble()  # all the run length encoding
size_hist_boot_all <- tibble() # counts of group sizes and lengths by bin
lifetm_hist_boot_all <- tibble() # counts of group sizes and lengths by bin

### go through the bootstrap replicate experiments
for (i in 1:n_reps) {
  print(paste("On iteration", i))
  
  rle_temp <- rle_data_list[[i]]
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

  # steps / tasks 
  # make a stacked tibble of the runs with actual groups (value != 0)
  rle_temp$bootrep <- i # code the rep number
  
  rle_boot_all <- bind_rows(rle_boot_all, rle_temp)  # all the run length encoding
  
  # compute histograms of group lifetimes and sizes with constant, identical bins
  ###### make a histogram for sizes #####
  size_hist <- hist(rle_temp$values, 
                   breaks = seq(0, 16), # go long - can truncate for plots
                   plot = FALSE
                   )

  ###### make a histogram for lifetimes #####
  lifetime_hist <- hist(rle_temp$lengths, 
                   breaks = seq(0, 20, 0.2), # go long - can truncate for plots
                   plot = FALSE
                   )
  
  # construct a temporary tibbles holding hist() outputs for this run
  # first sizes
  sz_hist_tib_temp <- tibble(size_mids = size_hist$mids,
                         size_cnts = size_hist$counts,
                         bootrep = i)
  
  size_hist_boot_all <- bind_rows(size_hist_boot_all, sz_hist_tib_temp)
  
  # then lifetimes
  lt_hist_tib_temp <- tibble(lifetm_mids = lifetime_hist$mids,
                          lifetm_cnts = lifetime_hist$counts,
                          bootrep = i)
  
  lifetm_hist_boot_all <- bind_rows(lifetm_hist_boot_all, lt_hist_tib_temp)
  
}

size_summary <- size_hist_boot_all %>% 
  group_by(size_mids) %>% 
  summarise(n_obs = n(),
            size_mean = mean(size_cnts),
            size_sd = sd(size_cnts),
            size_se = size_sd/sqrt(n_obs))

lifetm_summary <- lifetm_hist_boot_all %>% 
  group_by(lifetm_mids) %>% 
  summarise(n_obs = n(),
            lifetm_mean = mean(lifetm_cnts),
            lifetm_sd = sd(lifetm_cnts),
            lifetm_se = lifetm_sd/sqrt(n_obs))

### plotting
size_plt <- size_summary %>% 
  ggplot(aes(x = size_mids, y = size_mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(
    aes(ymin = size_mean - size_se, ymax = size_mean + size_se),
    width = 0.25  # Width of the error bars
  ) +
  labs(y = "Counts", x = "Group Size", title = title_str) +
  theme_minimal()

print(size_plt)

lfTm_plt <- lifetm_summary %>% 
  ggplot(aes(x = lifetm_mids, y = lifetm_mean)) +
  geom_bar(stat="identity") +
  geom_errorbar(
    aes(ymin = lifetm_mean - lifetm_se, ymax = lifetm_mean + lifetm_se),
    width = 0.25  # Width of the error bars
  ) +
  xlim(0, 6) +
  labs(y = "Counts", x = "Group Lifetime", title = title_str) +
  theme_minimal()

print(lfTm_plt)
