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
library(rstudioapi)
library(progress) # this script is going to take a while to run...
library(fpc)

######### function definitions ##################
# Define the function to perform DBSCAN clustering
# It takes the group labels (0 for no group), and adds
# them on as additional column
perform_dbscan <- function(data, min_objects, eps) {
  # Perform DBSCAN clustering
  cluster_result <- dbscan(data[, c("x", "y")], eps = eps, MinPts = min_objects)
  
  # Assign cluster labels to new "cluster" column
  data$cluster <- cluster_result$cluster
  data$iscore <- cluster_result$isseed
  
  return(data)
}
######### end function definitions ##################

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
  tmp = data.frame()
  
  # load the .RData files for the rats in this run
  for (j in 1:length(file_list)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    load(file_list[j])
    tmp <- rbind(tmp, xyt_dat)
    
  } # end of looping through files for this run
  
  # rename the combined file back to xyt_dat
  xyt_dat <- tmp
  
  # omit rows with NA values
  xyt_dat <- xyt_dat[complete.cases(xyt_dat$x, xyt_dat$y), ]
  
  ##### run DBScan
  # Set parameters
  min_objects <- 3 # Minimum number of objects in a cluster
  eps <- 100       # Maximum distance between two samples for 
  # them to be considered as in the same neighborhood
  
  # preform the clustering on each video frame
  # Group data by time and apply the perform_dbscan function
  xyt_dat <- xyt_dat %>%
    group_by(frame) %>% # group data by frame number
    group_modify(~ perform_dbscan(.x, 
                                  min_objects = min_objects, 
                                  eps = eps))
  
  ##### run rle analysis
  # make data frame without unneeded columns
  cluster_dat <- xyt_dat %>% select(rat_num, frame, cluster)
  # rat number cycles fast, frame cycles slowly
  
  # remove unneeded Big Kahuna data frame
  rm('xyt_dat')
  
  # pivot such that 
  # - rats are rows, 
  # - frames are columns, 
  # - and entries are cluster ID number
  # this will allow us to detect frame-to-frame continuity of clusters more
  # easily
  grps_tibble <- cluster_dat %>%
    pivot_wider(names_from = frame, values_from = cluster)
  
  # convert to a matrix so we can do maths more directly
  grps_matrix <- as.matrix(grps_tibble[,-1])
  mat_dims <- dim(grps_matrix)
  n_frames = mat_dims[2]
  
  # get maximum integer group label for the `for()` loop below
  max_grp_number <- max(grps_matrix)
  
  # Initialize group label x frame array for group member counts
  member_counts <- array(0, dim=c(max_grp_number, n_frames))
  
  # fill group label x frame array whose values are the number of 
  # members in that group
  for (i in 1:max_grp_number) {    # loop through the groups labels
    temp <- grps_matrix    # make a matrix whose entries are
    temp[temp == i] <- 1   # 1 for this group and
    temp[temp != i] <- 0.  # 0 for the other groups
    member_counts[i, ] <- colSums(temp) # number of members of this group for each frame
  }
  # We now have a matrix indicating whether a group (row) is present
  # on a given frame (column)
  
  # Now perform run length encoding (rle) to get a data frame of group lengths 
  # (in frames) and group sizes (# of rats).   
  # NB: doing this in separate `for()` loop from above for clarity.
  rle_raw <- tibble() # empty tibble to hold results
  for (i in 1:max_grp_number) {    # loop through the groups labels
    # Perform the run-length encoding for this row
    rle_output <- rle(member_counts[i, ])
    
    # the output of rle() is a list, so
    # convert the RLE result to a temporary tibble
    rle_tibble <- tibble(
      lengths = rle_output$lengths,
      values = rle_output$values,
      grp_label = i
    )
    
    # Append to the results to the main output tibble
    rle_raw <- bind_rows(rle_raw, rle_tibble)
    
  }
  
  # need to add a cumulative sum column of the lengths
  # to code the frame number at which clusters start
  
  
  
  
  
  ##################
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