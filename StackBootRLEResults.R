# make a stacked tibble of the bootstrapped rle results

debug_flag <- 1
if (debug_flag) {
  n_reps <- 100
  save_flag <- 0
}


# load libraries
library(tidyverse)

# load the file...

n_rats <- 3 # yes, this is hardcoded...

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

############### BOOTSTRAP DATA LOOP ####################
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
  
} # end of bootstrap loop

if (save_flag) {
  save(rle_boot_all, file= paste(n_rats, "rats_rle_boot_all.RData", sep = "_"))
}
