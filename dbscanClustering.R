# Install and load required packages
library(dplyr)
library(fpc)

# Define the function to perform DBSCAN clustering and remove subsets
find_clusters <- function(data, min_objects, eps) {
  # Perform DBSCAN clustering
  cluster_result <- dbscan(data[, c("x", "y")], eps = eps, minPts = min_objects)
  
  # Filter out noise points
  clustered_data <- data[cluster_result$cluster != 0,]
  
  # Assign cluster labels
  clustered_data$cluster <- cluster_result$cluster[cluster_result$cluster != 0]
  
  # Identify and remove smaller clusters that are subsets of larger clusters
  for (cluster_label in unique(clustered_data$cluster)) {
    cluster_points <- clustered_data[clustered_data$cluster == cluster_label,]
    other_clusters <- clustered_data[clustered_data$cluster != cluster_label,]
    subset_points <- other_clusters[rowSums(sapply(cluster_points[, c("x", "y")], 
                                                   function(pt) {
                                                     sqrt((other_clusters$x - pt[1])^2 + (other_clusters$y - pt[2])^2) <= eps
                                                   })) >= min_objects,]
    
    if (nrow(subset_points) > 0) {
      clustered_data <- clustered_data[!clustered_data$object_id %in% subset_points$object_id,]
    }
  }
  
  return(clustered_data)
}

# Set parameters
min_objects <- 3 # Minimum number of objects in a cluster
eps <- 0.5 # Maximum distance between two samples for them to be considered as in the same neighborhood

# Load your data into a tibble named "data" with columns "x", "y", "time", and "object_id"

# Group data by time and apply the find_clusters function
results <- data %>%
  group_by(time) %>%
  group_modify(~ find_clusters(.x, min_objects = min_objects, eps = eps))

# Print the results
print(results)
