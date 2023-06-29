# install.packages("ggplot2")
library(ggplot2)

n_steps <- 1000

# Initialize data frame for storing coordinates
df <- data.frame(
  time = rep(1:n_steps, 3),
  x = rep(NA, n_steps*3),
  y = rep(NA, n_steps*3),
  id = rep(c("obj1", "obj2", "obj3"), each = n_steps)
)

# Simulate coordinates
for (i in 1:n_steps) {
  
  # Objects start apart, come together, and move apart again in a sinusoidal pattern
  df$x[df$time == i] = c(
    100 * sin(i / 100) + 10,  # obj1
    100 * sin(i / 100) + 20,  # obj2
    100 * sin(i / 100) + 30   # obj3
  )
  
  df$y[df$time == i] = c(
    100 * cos(i / 100) + 1,  # obj1
    100 * cos(i / 100) + 2,  # obj2
    100 * cos(i / 100) + 3   # obj3
  )
}

# Plot
myplot <- 
ggplot(df, aes(x = x, y = y, color = id)) +
  geom_path() +
  theme_minimal() +
  labs(x = "X", y = "Y", title = "Silly Simulated Rats", color = "Object")

show(myplot)