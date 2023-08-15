# This is the script that does the clustering.

library(tidyverse)
library(fpc)

save_flag = TRUE # save out the tibble with the cluster columns?
plot_flag = TRUE # make plot?

# Select .RData file for analysis
# The file must contain a data frame "xyt_dat" with 4 columns:
# | frame | x | y | rat_num |

file_path <- rstudioapi::selectFile(caption = "Select RData File",
                                   filter = "RData Files (*.RData)",
                                   existing = TRUE)

load(file_path)

###########################
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
###########################

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

##### Name and save the file #######
if (save_flag) {
  file_name <- file.choose(new = TRUE)
  file_name <- paste0(file_name, '.RData')
  save(xyt_dat, file = file_name)
}
##########

##### optional plotting #####
if (plot_flag) {
  # plot of some sort
  all_dat_plot <- xyt_dat %>%
    ggplot(aes(x = frame, y = cluster, color = cluster)) +
    geom_jitter(height = 0.1, size = 2, alpha = 0.1)
  
  show(all_dat_plot)
}
#####

