# compute block properties

library(tidyverse)


file_path <- rstudioapi::selectFile(caption = "Select RData File",
                                    filter = "RData Files (*.RData)",
                                    existing = TRUE)

load(file_path)

# make data frame without unneeded columns
grouping_dat <- xyt_dat %>% select(rat_num, frame, cluster)

# pivot such that rats are rows, frames are columns, and entries are cluster
grps_tibble <- grouping_dat %>%
  pivot_wider(names_from = frame, values_from = cluster)

# convert to a matrix
grps_matrix <- as.matrix(grps_tibble[,-1])

# get maximum integer group label for the `for()` loop below
max_grp_number <- max(grps_matrix)

