# Visualize a single rat's data in x,y,t space

# load the essentials
library(tidyverse)
library(plotly)

# Pick your rat! (i.e. define the file path to single rat's data)
file_path <- "./data/3Rats/Average_Position_01/rat1_avg.csv"
# to do: have vars for condition, run, and rat then build path from that

# Read the .csv file into a data frame, skipping the first (header) row
xyt_data_raw <- read_csv(file_path, col_names = c("frame", "x", "y"), skip = 1)

# remove rows with NaNs
xyt_dat <- xyt_data_raw %>%
  filter(!is.na(x) & !is.na(y)) # keep only rows with no NaN position values

# Add a column indicating how many frames have elapsed since the last
# valid frame - i.e. how many NaN frames (minus 1) were skipped, if any.
# It's essentially a time step column.
xyt_dat <- xyt_dat %>% 
  mutate(f_diff = c(1, diff(frame))) # tack on a 1 at first time step

# make a plotly plot
fig <- xyt_dat %>% 
  plot_ly(x = ~x, y = ~y, z = ~frame, 
          type = 'scatter3d', 
          mode = 'lines',
          opacity = 0.3)

# display plot
show(fig)

# NaN diagnostics 

# How many NaN frames were there?
totNans <-  length(xyt_data_raw$frame) - length(xyt_dat$frame)

# How many not counting the initial ones?
midNans <- sum(xyt_dat$f_diff[xyt_dat$f_diff>1])

# so how many initial NaNs?
initNans = totNans - midNans

print(paste("There were", initNans, "initial NaNs"))
print(paste("and", midNans, "NaNs scattered about after that."))

# Look at these mid-run NaN frame jumps
print("The plot at the right shows where the middle ones were,")
print("and how big the gaps were (how many NaNs in a row")
plot(xyt_dat$f_diff)
