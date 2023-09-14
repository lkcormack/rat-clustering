# Within condition bootstapping

# install.packages(c("tidyverse", "fs"))
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
for (sub_dir in sub_dirs) {
  #print("getting subdirectories")
  #print(sub_dir)  # for debugging
  # Get a list of files in the current subdirectory
  #files_in_current_dir <- dir(sub_dir, full.names = TRUE)
  # load the list of files in this directory
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

for(i in 1:num_iterations) {
  
  sampled_files <- sample(all_files, n, replace = TRUE)
  
  
  # Load sampled data
#  sampled_data <- lapply(sampled_files, read.csv) %>% 
#    bind_rows() 
  
  # DBSCAN
  # ... 
  result <- "our histograms"
  
  results[[i]] <- result
}


