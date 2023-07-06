# Script to simulate rats grouping and ungrouping in a known fashion.
# They will do a random walk for a while, come together, walk, repeat

# packages
library(ggplot2)
library(plotly)

# number of time steps
n_steps <- 1000

# sd of random walk step sizse
sd_delta <- 20

# cage boundaries (in pixels - ask Marie for real ones)
x_min <- 0
x_max <- 1260
y_min <- 0
y_max <- 1260

n_rats <- 3 # number of rats: 3, 6, 9, or 15
n_groups <- 1 # not implemented yet!

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

#### Set initial coordinates for the little critters ###
init_x <- c(300, 1000, 1000)
init_y <- c(300, 300, 1000)

for (j in 0:(n_rats-1)) {
  xyt_dat$x[j*n_steps+1] <- init_x[j+1]
  xyt_dat$y[j*n_steps+1] <- init_y[j+1]
}
########

### Simulate coordinates for a random walk ###
for (i in 2:n_steps) {
  for (j in 0:(n_rats-1)) {
    xyt_dat$x[j*n_steps+i] <- xyt_dat$x[j*n_steps+1] + rnorm(1,0,sd_delta)
    xyt_dat$y[j*n_steps+i] <- xyt_dat$y[j*n_steps+1] + rnorm(1,0,sd_delta)
  }
}
##########

### Have the rats group in a couple of places ###
rendezvous = c(500, 500)
# subtract starting coord for each rat and add 500
for (i in 200:400) {
  for (j in 0:(n_rats-1)) {
    xyt_dat$x[j*n_steps+i] <- xyt_dat$x[j*n_steps+i] -
                              init_x[j+1] + rendezvous[1]
    xyt_dat$y[j*n_steps+i] <- xyt_dat$y[j*n_steps+i] -
                              init_y[j+1] + rendezvous[2]
  }
}

for (i in 600:800) {
  for (j in 0:(n_rats-1)) {
    xyt_dat$x[j*n_steps+i] <- xyt_dat$x[j*n_steps+i] -
                              init_x[j+1] + rendezvous[1]
    xyt_dat$y[j*n_steps+i] <- xyt_dat$y[j*n_steps+i] -
                              init_y[j+1] + rendezvous[2]
  }
}
##########

##### Name and save the file #######
file_name <- file.choose(new = TRUE)
file_name <- paste0(file_name, '.RData')
save(xyt_dat, file = file_name)
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