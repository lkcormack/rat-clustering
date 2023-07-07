n <- 3  # number of points

# Calculate the size of the grid
grid_size <- ceiling(sqrt(n)) + 1

# Create all possible grid points, leaving out the edges
grid_points <- expand.grid(x = seq(1000/(grid_size-1), 1000 - 1000/(grid_size-1), length.out = grid_size - 2), 
                           y = seq(1000/(grid_size-1), 1000 - 1000/(grid_size-1), length.out = grid_size - 2))

# If there are more grid points than needed, select a subset
if (nrow(grid_points) > n) {
  set.seed(42)  # set seed for reproducibility
  points <- grid_points[sample(nrow(grid_points), n), ]
} else {
  points <- grid_points
}

# See the points
points
