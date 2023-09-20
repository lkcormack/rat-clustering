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
root_dir <- selectDirectory(caption = "Select Directory",
                            label = "Select",
                            path = getActiveProject())

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

n <- length(files_in_current_dir)

num_iterations <- 3  # should go up on TACC

# Initialize storage
hist_data_list <- vector("list", num_iterations)
rle_raw <- tibble() # empty tibble to hold rle results

# condition ID for the filename
cond <- paste0('n_Rats', n_files)


# Here's the big bootstrapping loop
for(i in 1:num_iterations) {
  
  # create an empty data frame to hold the combined data
  sampled_data = data.frame()
  
  sampled_files <- sample(all_files, n, replace = TRUE)
  
  
  ###### Load sampled .RData files
  # Initialize an empty list to store the data frames
  df_list <- list()
  
  # Loop through each file in sampled_files
  for (file in sampled_files) {
    loaded_name <- load(file)
    df_list[[length(df_list) + 1]] <- get(loaded_name)
  }
  
  # Now bind all data frames together
  sampled_data <- bind_rows(df_list)
  
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
  
  result <- "our histograms"
  
  hist_data_list[[i]] <- result
  print(paste0("on iteration ", i))
}


