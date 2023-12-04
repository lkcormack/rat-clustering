###### Plot real data and boot data overlaid #########
library(tidyverse)

debug_flag <- 1
if (debug_flag) {
  n_reps <- 100
  save_flag <- 0
}
### Load files first! ####
## If the files are not in your working directory, you will need to 
## specify the path, or load the files "by hand" (and comment out the 
## load() lines below)

n_rats <- 15 # yes, this is hardcoded... could ask for input I suppose

# thresholding parameters
min_grp_size <- 3
min_grp_len <- 10

# load within rat data
# make filename
within_fname <- paste("./TACC_Data/Bootstrapping_results/", n_rats, 
               "RatsBootSummary.RData", sep = "")
print("Loading within-condition bootstrapping results... It'll be a minute...")
load(within_fname) # load data

# call make_boot_hist() function to compute histograms
within_summary <- make_boot_hist(rle_data_list, n_rats, 
                                 min_grp_size, min_grp_len)

# load big mama rat data
# make filename
mama_fname <- paste("./TACC_Data/MotherBootstrapping_results/", n_rats, 
                      "MotherRatsBootSummary.RData", sep = "")
print("Loading mama bootstrapping results ...It'll be a minute...")
load(mama_fname) # load data

# call make_boot_hist() function to compute histograms
mama_summary <- make_boot_hist(rle_data_list, n_rats, 
                                 min_grp_size, min_grp_len)


################### PLOTTING ###############
title_str <- paste(n_rats, "Rats") # number of rats for figure titles
## (or make your own)

##### Group sizes #####
size_overlay <- ggplot() +
  geom_bar(data = within_summary[[1]],
           aes(x = size_mids, y = size_mean), 
           stat="identity", position = position_dodge()) +
  
  geom_errorbar(data = within_summary[[1]],
                aes(x = size_mids, 
                    ymin = size_mean - size_sd, 
                    ymax = size_mean + size_sd),
                    width = 0.25,  # Width of the error bars
                    position = position_dodge(0.9)) +
  
  geom_bar(data = mama_summary[[1]],
           aes(x = size_mids, y = size_mean, alpha = 0.5, fill = "red"), 
           stat="identity", position = position_dodge()) +
  
  geom_errorbar(data = mama_summary[[1]],
                aes(x = size_mids, 
                    ymin = size_mean - size_sd, 
                    ymax = size_mean + size_sd),
                width = 0.25,  # Width of the error bars
                position = position_dodge(0.9)) +
  
  labs(y = "Counts", x = "Group Size", title = title_str) +
  theme_minimal()

print(size_overlay)

##### Group lifetimes #####
len_overlay <- ggplot() +
  geom_bar(data = within_summary[[2]], 
           aes(x = lifetm_mids, y = lifetm_mean), 
           stat="identity") +
  geom_errorbar(data = within_summary[[2]], 
                aes(x = lifetm_mids, 
                    ymin = lifetm_mean - lifetm_sd, 
                    ymax = lifetm_mean + lifetm_sd),
                width = 0.25  # Width of the error bars
  ) +
  geom_bar(data = within_summary[[2]], 
           aes(x = lifetm_mids, y = lifetm_mean), 
           stat="identity") +
  xlim(0, 6) +
  labs(y = "Counts", x = "Group Lifetime (sec)", title = title_str) +
  theme_minimal() 

print(len_overlay)

