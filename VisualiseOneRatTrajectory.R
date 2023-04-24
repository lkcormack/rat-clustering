# Visualize the rat data in x,y,t space

library(tidyverse)
library(plotly)

# Define the file path
file_path <- "./data/3Rats/Average_Position_01/rat1_avg.csv"

# Read the .csv file into a data frame, skipping the first row
xyt_data_raw <- read_csv(file_path, col_names = c("frame", "x", "y"), skip = 1)

# remove rows with NaNs
xyt_dat <- xyt_data_raw %>%
  filter(!is.na(x) & !is.na(y)) # drop rows with NaN positions

xyt_dat <- xyt_dat %>% 
  mutate(f_diff = c(1, diff(frame)))

# Print das tibble
#print(xyt_dat)

fig <- xyt_dat %>% 
  plot_ly(x = ~x, y = ~y, z = ~frame, type = 'scatter3d', mode = 'lines',
               opacity = 1)
# , line = list(width = 6, color = ~color, reverscale = FALSE))

fig

# plot_ly(x=xyt_dat$x, y=xyt_dat$y, z=xyt_dat$frame, type="scatter3d",
#        mode="lines")
