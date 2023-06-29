# This is the script that does the clustering.

library(tidyverse)
library(fpc)

# load xyt_dat
# Need to upgrade to file selection for stand-alone clustering
# and/or automate as part of a pipeline
load('spaceTime9Rats.RData')

###########################
# Define the function to perform DBSCAN clustering
# It takes the group labels (0 for no group), and adds
# them on as additional column
perform_dbscan <- function(data, min_objects, eps) {
  # Perform DBSCAN clustering
  cluster_result <- dbscan(data[, c("x", "y")], eps = eps, MinPts = min_objects)
  
  # Assign cluster labels to new "cluster" column
  data$cluster <- cluster_result$cluster
  
  return(data)
}
###########################

# Set parameters
min_objects <- 3 # Minimum number of objects in a cluster
eps <- 100       # Maximum distance between two samples for 
                 # them to be considered as in the same neighborhood

# preform the clustering on each video frame

# Group data by time and apply the perform_dbscan function
results <- xyt_dat %>%
  group_by(frame) %>% # group data by frame number
  group_modify(~ perform_dbscan(.x, 
                                min_objects = min_objects, 
                                eps = eps))

# plot of some sort
# all_dat_plot <- results %>% 
# ggplot(aes(x = frame, y = cluster, color = cluster)) +
#   geom_jitter(size = 2, alpha = 0.1)
#   
# show(all_dat_plot)

# make a tibble with just the clustered data
clustered_data <- results[results$cluster != 0, ]

# plot of some sort
clstr_dat_plot <- clustered_data %>% 
  ggplot(aes(x = frame, y = cluster, color = cluster)) +
  geom_jitter(size = 1, alpha = 0.1)

show(clstr_dat_plot)

