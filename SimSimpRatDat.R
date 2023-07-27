# Script to simulate rats grouping and ungrouping in a known fashion.
# They will do a random walk for a while, come together, walk, repeat

# ------ Packages ------
# plotting
library(ggplot2)
library(plotly)
# string printing
library(glue)

debug_flag <- TRUE # if TRUE, no file is saved.

n_rats <- 6 # number of rats: 3, 6, 9, or 15
n_groups <- 2 # requested number of groups

#####
# perhaps let user enter group sizes in a list. Like
# grp_sizes = c(4, 3) for a group of 4 and a group of 3...
# for now though, we'll do groups of 3
#####
rats_per_grp <- 3 # this is a constant for now

# Minimum group size is 3 rats (by in-house def.)
min_grp_sz <- 3

# Maximum number of groups is thus
# n_rats %/% min_grp_sz (quotient of n_rats/min_grp_sz)
max_n_groups <- n_rats %/% rats_per_grp

# check for valid combo of rats & groups
if (n_groups > max_n_groups) {
  warn_str <- glue("Too many groups requested!
                   Setting n_groups to {max_n_groups}.")
  warning(warn_str)
  n_groups <- max_n_groups
}

# number of time steps
n_steps <- 1000

# sd of random walk step sizse
sd_delta <- 3

# video dims (in pixels)
x_min <- 0
x_max <- 1280
y_min <- 0
y_max <- 720
# It's more complicated for the real data
# (cage is a subset of frame and is at an angle)
# It doesn't matter for this though

# Create vector of rat IDs
base_string <- "rat"
int_seq <- 1:n_rats  
rat_ids <- paste0(base_string, int_seq)

### Initialize data frame for storing coordinates ###
xyt_dat <- data.frame(
  frame = rep(1:n_steps, n_rats),
  x = rep(NA, n_steps*n_rats),
  y = rep(NA, n_steps*n_rats),
  rat_num = rep(rat_ids, each = n_steps)
)
########

##### Set initial coordinates for the little critters #####
# Compute starting coordinates on a grid in the cage.
# Calculate the size (side length) of the grid.
# We need the central part of the grid to hold
# whatever the next perfect square is above n_rats.
grid_size <- ceiling(sqrt(n_rats)) # grid is grid_size x grid_size big

# Calculate grid coordinates.
grid_points <- expand.grid(x = seq(0, 1000, 
                                   length.out = grid_size), 
                           y = seq(0, 1000, 
                                   length.out = grid_size))

# If there are more grid points than needed, select a subset.
if (nrow(grid_points) > n_rats) {
  set.seed(42)  # set seed for reproducibility
  points_un <- grid_points[sample(nrow(grid_points), n_rats), ]
} else {
  points_un <- grid_points
}
# `points_un` is now an n_rats x 2 data frame of 
# x, y starting point coordinates

# insert starting coords into main data frame
for (j in 0:(n_rats-1)) { #skip to first row for each rat
  xyt_dat$x[j*n_steps+1] <- points_un[j+1, 'x']
  xyt_dat$y[j*n_steps+1] <- points_un[j+1, 'y']
}
##### Done setting starting coordinates

##### Simulate coordinates for the random walks #####
for (i in 2:n_steps) {
  for (j in 0:(n_rats-1)) {
    xyt_dat$x[j*n_steps+i] <- xyt_dat$x[j*n_steps+(i-1)] + rnorm(1,0,sd_delta)
    xyt_dat$y[j*n_steps+i] <- xyt_dat$y[j*n_steps+(i-1)] + rnorm(1,0,sd_delta)
  }
}
# each rat is now doing a random walk "staying in their lanes"
##### Done setting random walks

##### Now for the tricky bit...                 #####
##### Have the rats group in a couple of places #####
rendezvous_un = c(200, 200)
rendezvouses <- data.frame(x = numeric(n_groups), 
                           y = numeric(n_groups))
for (i in 1:n_groups) {
  rendezvouses[i, ] <- rendezvous_un + i*100
}

# First group will rats 1, 2, 3, next will be 4, 5, 6, etc.
# subtract starting coord for each rat and add group offset
for (i in 200:400) {                             # cycle through frames
  for (k in 0:(n_groups-1)) {                      # and through groups
    for (j in 0:(rats_per_grp-1)) {              # and through rats w/in group
      # Each rat's set of rows is n_steps long
      le_index <- k*rats_per_grp*n_steps + j*n_steps + i
      
      xyt_dat$x[le_index] <-                    # new current coord equal
        xyt_dat$x[le_index] -                   # orig. current coord
        points_un[j+1, 'x'] +                   # minus starting coord
        rendezvouses[k+1, 'x']                  # plus rendezvous point
      
      xyt_dat$y[le_index] <-                    # new current coord equal
        xyt_dat$y[le_index] -                   # orig. current coord
        points_un[j+1, 'y'] +                   # minus starting coord
        rendezvouses[k+1, 'y']                  # plus rendezvous point
    }
  }
}

for (i in 600:800) {
  for (k in 0:(n_groups-1)) {                      # and through groups
    for (j in 0:(rats_per_grp-1)) {              # and through rats w/in group
      # Each rat's set of rows is n_steps long
      le_index <- k*rats_per_grp*n_steps + j*n_steps + i
      
      xyt_dat$x[le_index] <-                    # new current coord equal
        xyt_dat$x[le_index] -                   # orig. current coord
        points_un[j+1, 'x'] +                   # minus starting coord
        rendezvouses[k+1, 'x']                  # plus rendezvous point
      
      xyt_dat$y[le_index] <-                    # new current coord equal
        xyt_dat$y[le_index] -                   # orig. current coord
        points_un[j+1, 'y'] +                   # minus starting coord
        rendezvouses[k+1, 'y']                  # plus rendezvous point
    }
  }
}
#####

##### Name and save the file #######
if (!debug_flag) {
  file_name <- file.choose(new = TRUE)
  file_name <- paste0(file_name, '.RData')
  save(xyt_dat, file = file_name)
}
##########

# Plot
myplot <- 
ggplot(xyt_dat, aes(x = x, y = y, color = rat_num)) +
  geom_path(alpha = 0.2) +
  theme_minimal() +
  labs(x = "X", y = "Y", title = "Silly Simulated Rats", color = "rat num")

show(myplot)

## mo plotting ##

fig <- xyt_dat %>% 
  plot_ly(x = ~x, y = ~y, z = ~frame, color = ~rat_num,
          type = 'scatter3d', mode = 'lines', 
          colors = c("blue", "green", "red"),
          opacity = 0.1, 
          line = list(width = 6, opacity = 0.1)) %>% 
  layout(title = "Rats!",
         scene = list(
           xaxis = list(title = "x position"),
           yaxis = list(title = "y position"),
           zaxis = list(title = "time")
         ))

show(fig)