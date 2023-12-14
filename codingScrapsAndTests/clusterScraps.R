
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