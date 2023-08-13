#####
# Analyze groups in a condition
# This code (will...) 
#  let the user pick a condition (number of rats)
#  loop through the runs in that condition
#     combine the rat data files into one data frame
#     compute the group lengths
#     compute a histogram of the lengths
#     add the histogram to list 
#  save out the histogram data for this condition
####

library(tidyverse)

# Initialize an empty list to store the histogram data
hist_data_list <- list()

# load list of filenames for this condition
# dir_list <-  ...

##### loop through the runs in this condition
for (i in 1:length(dir_list)) {
  # load the list of files in this directory
  # file_list <-  ...
  
  # load the .RData files for the rats in this run
  for (j in 1:length(file_list)) {
    # combine into one data frame
    # temp <-  ...
    
  } # end of looping through files for this run
  
  # compute the histograms of group lengths for this run and store
  h <- hist(temp, probability = TRUE, plot = FALSE)
  
  # Create a data frame with counts, bin midpoints, and dataset ID
  df <- data.frame(
    dataset_id = i,
    counts = h$counts,
    bin_midpoints = (h$breaks[-length(h$breaks)] + h$breaks[-1]) / 2
  )
  
  # Append the histogram data to the list
  hist_data_list[[i]] <- df
  
}

# Combine all the data frames into a single data frame
hist_data_df <- do.call(rbind, hist_data_list)

# save out the data frame for this condition


##### Plotting