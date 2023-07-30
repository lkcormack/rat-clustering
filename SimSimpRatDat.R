# Script to simulate rats grouping and ungrouping in a known fashion.
# They will do a random walk for a while, come together, walk, repeat

# ------ Packages ------
# plotting
library(ggplot2)
library(plotly)
# string printing
library(glue)

debug_flag <- TRUE # if TRUE, no file is saved.

##### Things with which to play #####
### rats
n_rats <- 15        # number of rats: 3, 6, 9, or 15
n_groups <- 4      # requested number of groups

### sd for the random walks
sd_delta <- 3      # sd of random walk step size

### time
n_steps <- 1000   # number of time steps
n_grp_periods <- 3 # number of time periods when grouping occurs

#### End of adjustable parameters or "knobs" ####

##### Compute temporal split points for groups #####
n_breaks <-  2*n_grp_periods + 2 # split points and end points
t_breaks <- seq(0, n_steps, length.out = n_breaks)
t_breaks <- t_breaks[2:(n_breaks-1)]

#####
# perhaps let user enter group sizes in a list. Like
# grp_sizes = c(4, 3) for a group of 4 and a group of 3...
# for now though, we'll do groups of 3
rats_per_grp <- 3 # this is a constant for now

# Minimum group size is 3 rats (by in-house def.)
min_grp_sz <- 3

##### 
# check for valid combo of rats & groups
# Maximum number of groups is thus
max_n_groups <- n_rats %/% rats_per_grp

if (n_groups > max_n_groups) {
  warn_str <- glue("Too many groups requested!
                   Setting n_groups to {max_n_groups}.")
  warning(warn_str)
  n_groups <- max_n_groups
}

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

# Spatial extent of video (not currently respected, but whatever)
# video dims (in pixels)
x_min <- 0
x_max <- 1280
y_min <- 0
y_max <- 720

# Calculate grid coordinates.
grid_points <- expand.grid(x = seq(x_min, x_max, 
                                   length.out = grid_size), 
                           y = seq(y_min, y_max, 
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
for (j in 0:(n_rats-1)) { 
  xyt_dat$x[j*n_steps+1] <- points_un[j+1, 'x'] # skip to first row for each rat
  xyt_dat$y[j*n_steps+1] <- points_un[j+1, 'y'] # ditto
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
rendezvous_un = c(200, 200)                       # coords of first group
rendezvouses <- data.frame(x = numeric(n_groups), 
                           y = numeric(n_groups))
for (i in 1:n_groups) {
  rendezvouses[i, ] <- rendezvous_un + i*100.     # coords of subsequent groups
}

# First group will rats 1, 2, 3, next will be 4, 5, 6, etc.
# subtract starting coord for each rat and add group offset
for (time_grp in 1:(length(t_breaks)/2)) {
  strt <- floor(t_breaks[2*time_grp - 1]) # odd elements (start points)
  stp <- floor(t_breaks[2*time_grp]) # even elements (stopping points)
  
  for (i in strt:stp) {                             # cycle through frames
    for (k in 0:(n_groups-1)) {                     # and through groups
      for (j in 0:(rats_per_grp-1)) {              # and through rats w/in group
        # Each rat's set of rows is n_steps long
        le_index <- k*rats_per_grp*n_steps + j*n_steps + i
        
        xyt_dat$x[le_index] <-                    # new current coord equals the
          rendezvouses[k+1, 'x'] +                # rendezvous point plus
          rnorm(1, 0, 10)                         # some random noise
        
        xyt_dat$y[le_index] <-                    # new current coord equals the
          rendezvouses[k+1, 'y'] +                # rendezvous point plus
          rnorm(1, 0, 10)                         # some random noise
      }
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