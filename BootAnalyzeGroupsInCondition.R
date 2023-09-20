###### Within condition bootstapping
# Bootstrap analysis of groups in a condition
# This code (will...) 
#
#  let the user pick a condition (number of rats)
#  Need to change this to a hard-coded path for running one Lonestar6
#
# loop through bootstrap iterations
#  loop through the runs in that condition
#     make a random sample of rat data from all runs
#     load each rat's .RData file
#     combine the rat data files into one data frame
#     compute the group lengths
#     compute a histogram of the lengths
#     add the histogram to list 
#  save out the histogram data for this condition

# NOTE: MakeDataFilesFromCSVs.R must be used to create
# the .RData files in the directories before running this!

##### library loading ######
library(tidyverse)
library(rstudioapi) # won't be needed for Lonestar6
library(fs)         # may not be needed anymore
library(progress) # this script is going to take a while to run...
library(fpc)
#############

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


############ directory selection #################

####get path to condition directory #######
# root_dir <- selectDirectory(caption = "Select Directory",
#                             label = "Select",
#                             path = getActiveProject())

root_dir = "/Users/lkc/Documents/GitHub/rat-clustering/data/3Rats"
dir_list <- dir(root_dir, full.names = TRUE, recursive = FALSE)

# Initialize an empty list to hold all the files
all_files <- list()

# Loop through each subdirectory
#print("getting subdirectories") # for debbuging
for (sub_dir in dir_list) {
  #print(sub_dir)  # for debugging
  # Get a list of files in the current subdirectory
  files_in_current_dir <-
    list.files(path = sub_dir,
               pattern = ".RData",
               full.names = TRUE)
  n_files <- length(files_in_current_dir)
  
  # Append this list to the main list
  all_files <- c(all_files, files_in_current_dir)
}

# condition ID for the filename
cond <- paste0('n_Rats', n_files)

num_iterations <- 3  # should go up on TACC

# Initialize storage
hist_data_list <- vector("list", num_iterations)
rle_raw <- tibble() # empty tibble to hold rle results

# Create a progress bar object
pb <- progress_bar$new(total = num_iterations)

############### Here's the big bootstrapping loop ############
for(i in 1:num_iterations) {
  
  # create an empty data frame to hold the combined data
  sampled_data = data.frame()
  
  sampled_files <- sample(all_files, n_files, replace = TRUE)
  
  
  ###### Load sampled .RData files
  
  # load the .RData files for the rats in this run
  for (j in 1:length(sampled_files)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    load(sampled_files[[j]])
    sampled_data <- rbind(sampled_data, xyt_dat)
    
  } # end of looping through files for this run
  
  # rename the combined file back to xyt_dat
  xyt_dat <- sampled_data
  
  ##### NA removal #########################################
  # Find the frames with NaNs in either data column
  nan_frames = xyt_dat[is.na(xyt_dat$x) | is.na(xyt_dat$y), 'frame']
  
  # Keep the frames that are *not* a member of nan_frames
  # this will omit a rat's data for a given frame if one of its
  # buddies has a NA on that frame, even if the first rat's data is valid...
  # Which is what we need.
  xyt_dat <- xyt_dat[!xyt_dat$frame %in% nan_frames$frame, ]
 
  ##### run DBScan #########################################
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

  ##### run rle analysis ##################################
  # make data frame without unneeded columns
  cluster_dat <- xyt_dat %>% select(rat_num, frame, cluster)
  # rat number cycles fast, frame cycles slowly

  # remove unneeded Big Kahuna data frame
  #rm('xyt_dat')

  # pivot such that
  # - rats are rows,
  # - frames are columns,
  # - and entries are cluster ID number
  # this will allow us to detect frame-to-frame continuity of clusters more
  # easily
  
  # WTF is going on here?
  # grps_tibble <- cluster_dat %>%
  #   pivot_wider(names_from = frame, values_from = cluster)

  # # convert to a matrix so we can do maths more directly
  # grps_matrix <- as.matrix(grps_tibble[,-1])
  # mat_dims <- dim(grps_matrix)
  # n_frames = mat_dims[2]
  # 
  # # get maximum integer group label for the `for()` loop below
  # max_grp_number <- max(grps_matrix)
  # 
  # # Initialize group label x frame array for group member counts
  # member_counts <- array(0, dim=c(max_grp_number, n_frames))
  # 
  # # fill group label x frame array whose values are the number of 
  # # members in that group
  # for (j in 1:max_grp_number) {    # loop through the groups labels
  #   temp <- grps_matrix    # make a matrix whose entries are
  #   temp[temp == j] <- 1   # 1 for this group and
  #   temp[temp != j] <- 0.  # 0 for the other groups
  #   member_counts[j, ] <- colSums(temp) # number of members of this group for each frame
  # }
  # # We now have a matrix indicating whether a group (row) is present
  # # on a given frame (column)
  # 
  # # Now perform run length encoding (rle) to get a data frame of group lengths 
  # # (in frames) and group sizes (# of rats).   
  # # NB: doing this in separate `for()` loop from above for clarity.
  # for (j in 1:max_grp_number) {    # loop through the groups labels
  #   # Perform the run-length encoding for this row
  #   rle_output <- rle(member_counts[j, ])
  #   
  #   # the output of rle() is a list, so
  #   # convert the RLE result to a temporary tibble
  #   rle_tibble <- tibble(
  #     lengths = rle_output$lengths,
  #     values = rle_output$values,
  #     grp_label = j,
  #     run_label = i
  #   )
  #   
  #   # Append to the results to the main output tibble
  #   rle_raw <- bind_rows(rle_raw, rle_tibble)
  #   
  # }
  # 
  # # need to add a cumulative sum column of the lengths
  # # to code the frame number at which clusters start
  # 
  # Update the progress bar
  pb$tick()
  
  result <- "our histograms"
  
  hist_data_list[[i]] <- result
  print(paste0("on iteration ", i))
  
} # end of bootstrapping loop!

# Runs of zeros are runs of "no cluster" for that cluster ID
# So eliminate runs of zeros.
#cluster_lengths_sizes <- rle_raw[rle_raw$values != 0, ]


