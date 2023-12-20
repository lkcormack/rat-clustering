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
library(fpc)
#############

##### Do we save and/or plot?
save_flag = TRUE # save out the rle results?
plot_flag = FALSE # make plot? 

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

###get path to condition directory #######
# root_dir <- selectDirectory(caption = "Select Directory",
#                             label = "Select",
#                             path = getActiveProject())

# office
#root_dir = "/Users/lkc/Documents/GitHub/rat-clustering/data/3Rats/"
# laptop
root_dir = "/Users/lkcormack/Documents/GitHub/rat-clustering/data/3Rats"
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
############ end directory selection #################

# condition ID for the filename
cond <- paste0('n_Rats', n_files)

######### number of bootstrap repetitions to run ############
num_iterations <- 32  # should go up on TACC

############### Initialize storage #################
# cluster_data_list <- vector("list", num_iterations)
# hist_data_list <- vector("list", num_iterations)
rle_data_list <- vector("list", num_iterations)

# GOTCHA! This is the issue. This needs to be reset inside the loop...
#rle_raw <- tibble() # empty tibble to hold rle results

############### Here's the big bootstrapping loop ############
for(i in 1:num_iterations) {
  
  print(paste0("starting iteration ", i))
  
  # GOTCHA! This is the issue. This needs to be reset inside the loop...
  rle_raw <- tibble() # empty tibble to hold rle results
  
  # create an empty data frame to hold the combined data
  sampled_data = data.frame()
  # this is reset every iteration, so can't be the accumulation culprit
  
  # replace = false prevents identical rats in a run 
  # the bootstrapping is still valid because we're subsampling
  sampled_files <- sample(all_files, n_files, replace = FALSE)
  
  
  ###### Load sampled .RData files
  
  #### Okay, this is going to be clumsy as fuck, but...
  #### because the runs are different lengths ...
  ### we need to 
  ### load the sampled_files files once to get 
  ### their lengths, and then 
  ### load 'em again to load 'em...

  # vector to hold the lengths
  run_lengths = vector()
  # load the .RData files for the rats in this run
  for (j in 1:length(sampled_files)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    load(sampled_files[[j]])  # new xyt_dat data frame now on board
    run_lengths = c(run_lengths, nrow(xyt_dat)) # run lengths for each file
  } # end of looping through files for this run
  
  min_run_length = min(run_lengths) # need to truncate all data to this value

  # load the .RData files for the rats in this run
  for (j in 1:length(sampled_files)) {
    # print(paste("Loading rat", j)) # for debugging
    # combine into one data frame
    load(sampled_files[[j]])  # new xyt_dat data frame now on board
    # will need to save these when we analyze social hierarchy...
    id_string <- sub(".*/(Rat\\d+Run\\d+).*", "\\1", sampled_files[[j]])
    xyt_dat$rat_num = j # set rat ID to an int
    # print(nrow(xyt_dat))
    sampled_data <- rbind(sampled_data, xyt_dat[1:min_run_length, ])
    
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
  grps_tibble <- cluster_dat %>%
    pivot_wider(names_from = frame, values_from = cluster)

  # nrow(cluster_dat) == nrow(grps_tibble)*ncol(grps_tibble) - n_files
  # this test passes!
  
  # convert to a matrix so we can do maths more directly
  grps_matrix <- as.matrix(grps_tibble[,-1])
  mat_dims <- dim(grps_matrix)
  n_frames = mat_dims[2]

  # length(grps_matrix) == nrow(cluster_dat)
  # this test passes (length() for a matrix is number of elements)
  
  # get maximum integer group label for the `for()` loop below
  max_grp_number <- max(grps_matrix) 

  # only look for groups if they're are any!
  if (max_grp_number > 0) {
    
    # # Initialize group label x frame array for group member counts
    member_counts <- array(0, dim=c(max_grp_number, n_frames))
    
    # fill group label x frame array whose values are the number of
    # members in that group
    
    for (j in 1:max_grp_number) {    # loop through the groups labels
      temp <- grps_matrix    # make a matrix whose entries are
      temp[temp == j] <- 1   # 1 for this group and
      temp[temp != j] <- 0.  # 0 for the other groups
      member_counts[j, ] <- colSums(temp) # number of members of this group for each frame
    }
    # We now have a matrix indicating how many rats (entry) are in a group (row) 
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
      # Note!! The "grp_label" refers to the group number we're running the 
      # rle on. So runs of 0s will still have a label >= 1
      
      # Append to the results to the main output tibble
      rle_raw <- bind_rows(rle_raw, rle_tibble)
      
    }
    
  } # if

  # maybe add a cumulative sum column of the lengths
  # to code the frame number at which clusters start
  
  rle_data_list[[i]] <- rle_raw

  # cl_lgth_sz_temp <- rle_tibble[rle_tibble$values != 0, ]
  # if (nrow(cl_lgth_sz_temp) > 0) {
  #   hist_data_list[[i]] <- hist(cl_lgth_sz_temp$lengths, 30)
  # }
  # else {
  #   hist_data_list[[i]] <- "nope"
  # }

  print(paste0("done with iteration ", i))
  
} 
################# end of bootstrapping loop! ################

##### Saving
if (save_flag) {
  # assemble a file name
  fname_str <- paste0(n_files, "RatsBootSummary.RData") 
  
  # save out the data frame for this condition as a .RData file
  save(rle_data_list,   # rle output with only actual groups
       file = fname_str)
}

