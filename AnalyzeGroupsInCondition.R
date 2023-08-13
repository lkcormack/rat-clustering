#####
# Analyze groups in a condition
# This code (will...) 
#  let the user pick a condition (number of rats)
#  loop through the runs in that condition
#     load each rat's .RData file
#     combine the rat data files into one data frame
#     compute the group lengths
#     compute a histogram of the lengths
#     add the histogram to list 
#  save out the histogram data for this condition
####


library(tidyverse)
library(progress) # this script is going to take a while to run...

# Initialize an empty list to store the histogram data
hist_data_list <- list()

##### load list of directory names for this condition
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

##### loop through the runs in this condition
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
  xyt_dat = data.frame()
  
  # load the .RData files for the rats in this run
  for (j in 1:length(file_list)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    tmp <- load(file_list[j])
    xyt_dat <- rbind(xyt_dat, tmp)
    
  } # end of looping through files for this run
  
  # omit rows with NA values
  xyt_dat <- xyt_dat[complete.cases(xyt_dat$x, xyt_dat$y), ]
  
  # run DBScan
  
  # run rle analysis
  
  # compute the histograms of group lengths for this run and store
#  h <- hist(temp, probability = TRUE, plot = FALSE)
  
  # Create a data frame with counts, bin midpoints, and dataset ID
  # df <- data.frame(
  #   dataset_id = i,
  #   counts = h$counts,
  #   bin_midpoints = (h$breaks[-length(h$breaks)] + h$breaks[-1]) / 2
  # )
  
  # Append the histogram data to the list
  # hist_data_list[[i]] <- df

  # Update the progress bar
  pb$tick()
  
}

# Combine all the data frames into a single data frame
# hist_data_df <- do.call(rbind, hist_data_list)

# save out the data frame for this condition


##### Plotting