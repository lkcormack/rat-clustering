make_boot_hist <- function(rle_data_list, n_rats, min_grp_size, min_grp_len) {
  
  ####### PREPARE AND ANALYZE BOOTSTRAP DATA ########
  
  # get number of bootstrap replications
  n_reps <- length(rle_data_list)
  n_reps <- 300 # for testing
  
  ### make tibbles for bootstrapped summaries ###
  ### need to pre-allocate to save time hopefully! ###
  rle_boot_all <- tibble()  # all the run length encoding
  size_hist_boot_all <- tibble() # counts of group sizes and lengths by bin
  lifetm_hist_boot_all <- tibble() # counts of group sizes and lengths by bin
  
  ############### BOOTSTRAP DATA LOOP ####################
  ### go through the bootstrap replicate experiments
  ### hardcode n_reps to 1000 or whatever if needed
  for (i in 1:n_reps) {
    print(paste("On iteration", i))
    
    rle_temp <- rle_data_list[[i]] # get the ith bootstrap replicate tibble
    rle_data_list[[i]] <- tibble() # wipe the tibble to save memory
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
  
  # Return a list containing the bin centers and counts for the size 
  # and lifetime histograms
  return(list(size_summary, lifetm_summary))
}
