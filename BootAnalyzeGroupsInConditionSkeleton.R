# Within condition bootstapping

library(tidyverse)
library(rstudioapi)
library(fs)

root_dir <- selectDirectory(caption = "Select Directory",
                            label = "Select",
                            path = getActiveProject())

sub_dirs <- dir(root_dir, full.names = TRUE, recursive = FALSE)

# Initialize an empty list to hold all the files
all_files <- list()

# Loop through each subdirectory
#print("getting subdirectories") # for debbuging
for (sub_dir in sub_dirs) {
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
results <- vector("list", num_iterations)

# Here's the big bootstrapping loop
for(i in 1:num_iterations) {
  
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
  
  
  ######## All the Analysis code goes here
  # ... DBSCAN
  
  result <- "our histograms"
  
  results[[i]] <- result
}


