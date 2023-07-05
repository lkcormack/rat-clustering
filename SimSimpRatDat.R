# Script to simulate rats grouping and ungrouping in a known fashion.
# Hi Marie!
# packages
library(ggplot2)
library(plotly)

n_steps <- 1000
sd_delta <- 1

# Initialize data frame for storing coordinates
df <- data.frame(
  time = rep(1:n_steps, 3),
  x = rep(NA, n_steps*3),
  y = rep(NA, n_steps*3),
  id = rep(c("rat1", "rat2", "rat3"), each = n_steps)
)

# Simulate coordinates
for (i in 1:n_steps) {
  
  # rats start apart, come together, and move apart again in a sinusoidal pattern
  # need to clean this up
  df$x[df$time == i] = 100 * sin(i / 100) + c(1, 2, 3) * cos(i / 100)
  df$y[df$time == i] = 100 * cos(i / 100) + c(1, 2, 3) * sin(i / 100)
  
  if (i %% 100 == 0) {  # every 100 steps, rats converge
    df$x[df$time == i] = mean(df$x[df$time == i])
    df$y[df$time == i] = mean(df$y[df$time == i])
  }
}

# Plot
myplot <- 
ggplot(df, aes(x = x, y = y, color = id)) +
  geom_path() +
  theme_minimal() +
  labs(x = "X", y = "Y", title = "Silly Simulated Rats", color = "rat num")

show(myplot)

## mo plotting ##

fig <- df %>% 
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