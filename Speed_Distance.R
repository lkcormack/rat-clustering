# Get binned velocity and total distance data for rats

library(tidyverse)
library(rstudioapi)
library(progress) # this script is going to take a while to run...
library(fpc)
library(glue)

BIN = 100 # frames
FPS = 60

# def function to get abs distance between two points
abs_distance <- function(x1, y1, x2, y2) {
  abs(sqrt((x1 - x2)^2 + (y1 - y2)^2))
}

# Pick a Condition
dir_path <- selectDirectory(caption = "Select Directory",
                            label = "Select",
                            path = getActiveProject())

# get list of the directories (runs) in in this condition
dir_list <- list.dirs(path = dir_path,
                      recursive = FALSE,
                      full.names = TRUE)
n_runs <- length(dir_list) # should always be 15

# Create a progress bar object
pb <- progress_bar$new(total = n_runs)

############### big momma loop #############################
for (i in 1:length(dir_list)) {
  # print(paste("In", dir_list[i])) # for debugging
  # load the list of files in this directory
  file_list <-
    list.files(path = dir_list[i],
               pattern = ".RData",
               full.names = TRUE)
  n_files <- length(file_list)

  # condition ID for the filename
  cond <- paste0('n_Rats', n_files)

  # create an empty data frame to hold the combined data
  tmp = data.frame()

  # load the .RData files for the rats in this run
  for (j in 1:length(file_list)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    load(file_list[j])
    tmp <- rbind(tmp, xyt_dat)

  } # end of looping through files for this run
  
  xyt_dat <- tmp
  
  ##### NA removal #########################################
  # Find the frames with NaNs in either data column
  nan_frames = xyt_dat[is.na(xyt_dat$x) | is.na(xyt_dat$y), 'frame']
  
  # Keep the frames that are *not* a member of nan_frames
  # this will omit a rat's data for a given frame if one of its
  # buddies has a NA on that frame, even if the first rat's data is valid...
  # Which is what we need.
  xyt_dat <- xyt_dat[!xyt_dat$frame %in% nan_frames$frame, ]
  
  #########################################################
  
  # create column that is the absolute val of change in distance
  xyt_dat <- xyt_dat %>% mutate(delta_pos = abs_distance(x, y, lag(x), lag(y)))
  
  # drop the first frame for each rat because its value is NULL
  xyt_dat<-xyt_dat[!(xyt_dat$frame==0),]
  
  View(xyt_dat)
  
  # calculate expected number of bins
  rats <- unique(xyt_dat$rat_num) # list of rat nums
  num_rats <- length(rats)
  exp_bins <- as.integer(length(xyt_dat$frame) / (length(rats) * BIN))
  
  # final data frame for all rats velocity bins
  vel_bin_dat <- data.frame(matrix(0, nrow = exp_bins, ncol = 1))
  
  # total distance for all rats instantaneous >? why do emelents becomes ints when added to list
  total_dist <- c()
  
  # go through all rat nums 
  for (k in 1:length(rats)) {
    print(rats[k])
    
    # get all rows for a single rat
    new_dat <- xyt_dat[xyt_dat$rat_num == rats[k],]
    traveled <-sum(new_dat$delta_pos)
    total_dist <- append(total_dist, traveled)
    
    # create data to store bin velocity for single rat
    col_name = glue('rat_{k}')
    cols =  c(col_name)
    
    
    new_bins = c() # holds binned velocity for one rat
    b = as.integer(0) # tracks how far into a bin we are
    sum = as.double(0) # tracks sum of values in bin
    # go through each row for single rat
    for (m in 1:length(new_dat$frame)) {
      if (b == BIN) {
        # if we have gone through BIN number of frames, add new entry and reset counter/sum
        sum <- sum / BIN
        new_bins <- c(new_bins, sum)
        b = 0
        sum = 0
      }
      
      sum = sum + (as.double(new_dat[m, 'delta_pos']))
      b = b + 1
    }
    # add bins for one rat to collective list
    vel_bin_dat[col_name] <- new_bins
  }
  # maybe there is a work around for this but I found that to add a list to an empty dataframe,
  # the initial length dimensions have to match, so here I am just dropping the empty column I made initally
  vel_bin_dat <- vel_bin_dat[ , 2:length(vel_bin_dat)]
  View(vel_bin_dat)
  
  break
}




