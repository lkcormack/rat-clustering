# Visualize the rat data in x,y,t space

library(tidyverse)

# Define the file path
file_path <- "./data/3Rats/Average_Position_01/rat1_avg.csv"

# Read the .csv file into a data frame, skipping the first row
xyt_data <- read_csv(file_path, col_names = c("frame", "x", "y"), skip = 1)

# remove leading and trailing rows with NaNs
xyt_data <- xyt_data %>%
  slice(which.max(!is.na(x) & !is.na(y)):n())

# Print das tibble
print(xyt_data)