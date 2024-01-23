###### Plot real data and boot data overlaid #########
library(tidyverse)

### Load files first! ####
## If the files are not in your working directory, you will need to 
## specify the path, or load the files "by hand" (and comment out the 
## load() lines below)

n_rats <- 15 # yes, this is hardcoded...

### e.g. load("6RatsClusterSummary.RData")
#load("15RatsClusterSummary.RData")
#load(paste0("/Users/michaelpasala/Research/Results/Cluster/", n_rats, "RatsClusterSummary.RData")) # michael's dirs

# load boot rle_data_list
#load("15RatsBootSummary.RData")
#load(paste0("/Users/michaelpasala/Research/Results/Mother-50/", n_rats, "MotherRatsBootSummary.RData")) # michael's dirs

### files loaded ###


title_str <- paste(max(cluster_dat$rat_num), "Rats") # number of rats for figure titles
## (or make your own)

# thresholding parameters
min_grp_size <- 3
min_grp_len <- 10

####### PREPARE AND ANALYZE BOOTSTRAP DATA ########

# get number of bootstrap replications
n_reps <- length(rle_data_list)

# strings for output
title_str <- paste(n_rats, "Rats", n_reps, "Replicates") 

### make tibbles for bootstrapped summaries ###
rle_boot_all <- tibble()  # all the run length encoding
size_hist_boot_all <- tibble() # counts of group sizes and lengths by bin
lifetm_hist_boot_all <- tibble() # counts of group sizes and lengths by bin

############### BOOTSTRAP DATA LOOP ####################
### go through the bootstrap replicate experiments
### hardcode n_reps to 1000 or whatever if needed
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
                        breaks = seq(0, 20, 0.2), # go long - can truncate for plots
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

################### PLOTTING ###############
##### Group sizes #####
size_overlay <- ggplot() +
  geom_bar(data = size_summary, 
           aes(x = size_mids, y = size_mean), 
           stat="identity") +
  geom_errorbar(data = size_summary,
                aes(x = size_mids, 
                    ymin = size_mean - size_sd, 
                    ymax = size_mean + size_sd),
                width = 0.25  # Width of the error bars
  ) +
   geom_histogram(data = cluster_lengths_sizes,
                  aes(x = values),
                  breaks = seq(0, 16), fill = "red", alpha = 0.7) +
  labs(y = "Counts", x = "Group Size", title = title_str) +
  theme_minimal()

print(size_overlay)

##### Group lifetimes #####
# threshold for minimum group lifetime
plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > min_grp_len, ]
plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds

len_overlay <- ggplot() +
  geom_errorbar(data = lifetm_summary, 
                aes(x = lifetm_mids, 
                    ymin = lifetm_mean - lifetm_sd, 
                    ymax = lifetm_mean + lifetm_sd),
                width = 0.25  # Width of the error bars
  ) +
  geom_bar(data = lifetm_summary, 
           aes(x = lifetm_mids, y = lifetm_mean), 
           stat="identity") +
  geom_histogram(data = plt_lengths, aes(x = lengths),
                  breaks = seq(0, 20, 0.2), fill = "red", alpha = 0.5) +
  xlim(0, 6) +
  labs(y = "Counts", x = "Group Lifetime (sec)", title = title_str) +
  theme_minimal() 

print(len_overlay)

