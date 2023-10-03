# Analyze bootstrapping RLE results
library(tidyverse)

# load rle_data_list
load("3RatsBootSummary.RData")
n_rats <- 3 # yes, this is hardcoded...

# thresholding params
min_grp_size <- 3
min_grp_len <- 10

# get number of bootstrap replications
n_reps <- length(rle_data_list)

title_str <- paste(n_rats, "Rats", n_reps, "Replicats") 

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
  # compute histograms of group lifetimes and sizes with constant, identical bins
  # make a tibbles with columns
  # | boot rep number | bin (midpoint?) | size |
  # and
  # | boot rep number | bin (midpoint?) | lifetimes |
  # or probably make just one tibble?
  
  ####### below are temp placeholders #####
  
  ###### make a histogram for lifetimes #####
  lifetime_hist <- hist(rle_temp$lengths, 
                   breaks = seq(0, 6, 0.2), 
                   plot = FALSE
                   )
  
}