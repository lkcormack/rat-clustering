library(dplyr)
library(fpc)

# load xyt_dat
load('spaceTimeRats.RData')

# Define the function to perform DBSCAN clustering
perform_dbscan <- function(data, min_objects, eps) {
  # Perform DBSCAN clustering
  cluster_result <- dbscan(data[, c("x", "y")], eps = eps, MinPts = min_objects)
  
  # Assign cluster labels
  data$cluster <- cluster_result$cluster
  
  return(data)
}

# Set parameters
min_objects <- 3 # Minimum number of objects in a cluster
eps <- 100 # Maximum distance between two samples for them to be considered as in the same neighborhood

# Load your data into a tibble named "data" with columns "x", "y", "time"

# Group data by time and apply the perform_dbscan function
results <- xyt_dat %>%
  group_by(frame) %>%
  group_modify(~ perform_dbscan(.x, min_objects = min_objects, eps = eps))

# plot of some sort
all_dat_plot <- results %>% 
ggplot(aes(x = frame, y = cluster, color = cluster)) +
  geom_jitter(size = 2, alpha = 0.1)
  
show(all_dat_plot)

# make a tibble with just the clustured data
clustered_data <- results[results$cluster != 0,]

# plot of some sort
clstr_dat_plot <- clustered_data %>% 
  ggplot(aes(x = frame, y = cluster, color = cluster)) +
  geom_jitter(size = 2, alpha = 0.1)

show(clstr_dat_plot)

