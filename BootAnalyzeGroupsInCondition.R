# Within condition bootstapping

install.packages(c("tidyverse", "fs"))
library(tidyverse)
library(fs)

root_dir <- choose.dir()

sub_dirs <- dir(root_dir, full.names = TRUE, recursive = FALSE)

# Initialize an empty list to hold all the files
all_files <- list()

# Loop through each subdirectory
for (sub_dir in sub_dirs) {
  
  # Get a list of files in the current subdirectory
  files_in_current_dir <- dir(sub_dir, full.names = TRUE)
  
  # Append this list to the main list
  all_files <- c(all_files, files_in_current_dir)
}

n <- length(files_in_current_dir)

num_iterations <- 100  # should go up on TACC
results <- vector("list", num_iterations)

for(i in 1:num_iterations) {
  sampled_files <- sample(all_files, n, replace = TRUE)
  
  # Load sampled data
  sampled_data <- lapply(sampled_files, read.csv) %>% 
    bind_rows() 
  
  # DBSCAN
  # ... 
  result <- "our histograms"
  
  results[[i]] <- result
}


