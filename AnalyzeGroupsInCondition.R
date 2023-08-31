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

# NOTE: MakeDataFilesFromCSVs.R must be used to create
# the .RData files in the directories before running this!

#####

library(tidyverse)
library(rstudioapi)
library(progress) # this script is going to take a while to run...
library(fpc)

##### Do we save and/or plot?
save_flag = FALSE # save out the rle results?
plot_flag = TRUE # make plot?

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

##### get directory names for this condition ##############
# Pick a Condition
dir_path <- selectDirectory(caption = "Select Directory",
                            label = "Select",
                            path = getActiveProject())

# get list of the directories (runs) in in this condition
dir_list <- list.dirs(path = dir_path, 
                      recursive = FALSE, 
                      full.names = TRUE)
n_runs <- length(dir_list) # should always be 15

# Initialize storage
hist_data_list <- list() # empty list to store the histogram data
rle_raw <- tibble() # empty tibble to hold rle results

# Create a progress bar object
pb <- progress_bar$new(total = n_runs)

############### big momma loop #############################
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
  for (j in 1:max_grp_number) {    # loop through the groups labels
    temp <- grps_matrix    # make a matrix whose entries are
    temp[temp == j] <- 1   # 1 for this group and
    temp[temp != j] <- 0.  # 0 for the other groups
    member_counts[j, ] <- colSums(temp) # number of members of this group for each frame
  }
  # We now have a matrix indicating whether a group (row) is present
  # on a given frame (column)
  
  # Now perform run length encoding (rle) to get a data frame of group lengths 
  # (in frames) and group sizes (# of rats).   
  # NB: doing this in separate `for()` loop from above for clarity.
  for (j in 1:max_grp_number) {    # loop through the groups labels
    # Perform the run-length encoding for this row
    rle_output <- rle(member_counts[j, ])
    
    # the output of rle() is a list, so
    # convert the RLE result to a temporary tibble
    rle_tibble <- tibble(
      lengths = rle_output$lengths,
      values = rle_output$values,
      grp_label = j,
      run_label = i
    )
    
    # Append to the results to the main output tibble
    rle_raw <- bind_rows(rle_raw, rle_tibble)
    
  }
  
  # need to add a cumulative sum column of the lengths
  # to code the frame number at which clusters start
  
  # Update the progress bar
  pb$tick()
  
} ###### End of the Big Momma loop through runs; index variable i ######

# Runs of zeros are runs of "no cluster" for that cluster ID
# So eliminate runs of zeros.
cluster_lengths_sizes <- rle_raw[rle_raw$values != 0, ]

##### Saving
# assemble a file name
fname_str <- paste0(n_files, "RatsClusterSummary.RData") 

# save out the data frame for this condition as a .RData file
save(xyt_dat,                 # The Big Kahuna - has all the things (except NaNs)
     cluster_dat,             # subset of xyt_dat; just rat, frame, and cluster ID
     rle_raw,                 # run length encoding output including 0s (no group)
     cluster_lengths_sizes,   # rle output with only actual groups
     file = fname_str)

##### Plotting
if (plot_flag) {
  title_str <- paste(n_files, "Rats") # number of rats for figure titles

  # histograms of cluster lifetimes
  len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
  plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
  plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds
  
  # histograms of lifetimes; runs by color
  clstr_len_plot <- plt_lengths %>%
    ggplot(aes(x = lengths, color = as.factor(run_label))) +
    geom_freqpoly(bins = 30, alpha = 0.4, position = "identity") +
    ggtitle(title_str, subtitle = "lifetimes; runs by color") +
    xlab("cluster length (seconds)")
  show(clstr_len_plot)
 
  # histograms of lifetimes collapsed across run
  all_clstr_len_plot <- plt_lengths %>%
    ggplot(aes(x = lengths)) +
    geom_histogram(bins = 30, fill = "blue", alpha = 0.7) +
    ggtitle(title_str, subtitle = "lifetimes; all runs combined") +
    xlab("cluster length (seconds)")
  show(all_clstr_len_plot)
  
  if (n_files > 3) {  # these plots don't make sense for 3 rats
    # histograms of group sizes; runs by color
    clstr_size_plot <- cluster_lengths_sizes %>%
      ggplot(aes(x = values, fill = as.factor(run_label))) +
      geom_histogram(bins = 30, alpha = 0.4, position ="identity") +
      ggtitle(title_str, subtitle = "cluster sizes; runs by color") +
      xlab("cluster size")
    show(clstr_size_plot)
    
    # histograms of group sizes collapsed across run
    all_clstr_size_plot <- cluster_lengths_sizes %>%
      ggplot(aes(x = values)) +
      geom_histogram(bins = 30, fill = "blue", alpha = 0.7) +
      ggtitle(title_str, subtitle = "cluster sizes; all runs combined") +
      xlab("cluster size")
    show(all_clstr_size_plot)
    
    p <- plt_lengths %>% 
      ggplot(aes(x = values, y =  lengths)) + 
      geom_jitter(width = 0.2, height = 0, alpha = 0.2) +
      ggtitle(title_str, subtitle = "size vs. duration") + 
      xlab("cluster size") +
      ylab("duration (seconds)")
    show(p)
  } # end plots for 6 or more rats
}

##### some stuff
print(paste("Biggest cluster is ", max(plt_lengths$values), "rats."))
print(paste("Longest cluster lifetime is", max(plt_lengths$lengths), "seconds."))
