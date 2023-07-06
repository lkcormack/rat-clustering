# This is the script that does the clustering.

library(tidyverse)
library(fpc)

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
all_dat_plot <- results %>%
ggplot(aes(x = frame, y = cluster, color = cluster)) +
  geom_jitter(height = 0.1, size = 2, alpha = 0.1)

show(all_dat_plot)

# make a tibble with just the clustered data
# clustered_data <- results[results$cluster != 0, ]

# plot of some sort
# clstr_dat_plot <- clustered_data %>% 
#   ggplot(aes(x = frame, y = cluster, color = cluster)) +
#   geom_jitter(height = 0.2, size = 1, alpha = 0.1)
# 
# show(clstr_dat_plot)

