# Script to simulate rats grouping and ungrouping in a known fashion.
# They will do a random walk for a while, come together, walk, repeat

# packages
library(ggplot2)
library(plotly)

# number of time steps
n_steps <- 1000

# sd of random walk step sizse
sd_delta <- 1

# cage boundaries (in pixels - ask Marie for real ones)
x_min <- 0
x_max <- 1260
y_min <- 0
y_max <- 1260

# Initialize data frame for storing coordinates
n_rats <- 3 # need to code building of ID list.. only 3 allowed for now
xyt_dat <- data.frame(
  time = rep(1:n_steps, n_rats),
  x = rep(NA, n_steps*n_rats),
  y = rep(NA, n_steps*n_rats),
  id = rep(c("rat1", "rat2", "rat3"), each = n_steps)
)

# Set initial coordinates for the little critters
init_x <- c(100, 1000, 1000)
init_y <- c(100, 100, 1000)

for (j in 0:(n_rats-1)) {
  xyt_dat$x[j*n_steps+1] <- init_x[j+1]
  xyt_dat$y[j*n_steps+1] <- init_y[j+1]
}

# Simulate coordinates
for (i in 2:n_steps) {
  for (j in 0:(n_rats-1)) {
    # rats start apart
    # the equality test is to get all three rats
    xyt_dat$x[j*n_steps+2] <- xyt_dat$x[j*n_steps+1] + rnorm(1,0,sd_delta)
    xyt_dat$y[j*n_steps+2] =  xyt_dat$y[j*n_steps+1] + rnorm(1,0,sd_delta)
    
    # if (i %% 100 == 0) {  # every 100 steps, rats converge
    #   xyt_dat$x[df$time == i] = mean(xyt_dat$x[xyt_dat$time == i])
    #   xyt_dat$y[df$time == i] = mean(xyt_dat$y[xyt_dat$time == i])
    # }
  }
}

# Plot
myplot <- 
ggplot(xyt_dat, aes(x = x, y = y, color = id)) +
  geom_path() +
  theme_minimal() +
  labs(x = "X", y = "Y", title = "Silly Simulated Rats", color = "rat num")

show(myplot)

## mo plotting ##

fig <- xyt_dat %>% 
  plot_ly(x = ~x, y = ~y, z = ~time, color = ~id,
          type = 'scatter3d', mode = 'lines', 
          colors = c("blue", "green", "red"),
          opacity = 0.3, 
          line = list(width = 6, opacity = 0.3)) %>% 
  layout(title = "Rats!",
         scene = list(
           xaxis = list(title = "x position"),
           yaxis = list(title = "y position"),
           zaxis = list(title = "time")
         ))

show(fig)