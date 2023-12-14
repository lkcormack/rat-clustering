n <- 6  # number of points

# Calculate the size (side length) of the grid.
# We need the central part of the grid to hold
# whatever the next perfect square is above n.
grid_size <- ceiling(sqrt(n)) # grid is grid_size x grid_size big

# Calculate grid coordinates.
grid_points <- expand.grid(x = seq(0, 1000, 
                                   length.out = grid_size), 
                           y = seq(0, 1000, 
                                   length.out = grid_size))

# If there are more grid points than needed, select a subset.
 if (nrow(grid_points) > n) {
   set.seed(42)  # set seed for reproducibility
   points <- grid_points[sample(nrow(grid_points), n), ]
 } else {
   points <- grid_points
 }

# See the points
print(grid_points)
print(points)
