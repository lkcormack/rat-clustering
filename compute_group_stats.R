# compute block properties

library(tidyverse)


file_path <- rstudioapi::selectFile(caption = "Select RData File",
                                    filter = "RData Files (*.RData)",
                                    existing = TRUE)

load(file_path)

# make data frame without unneeded columns
grouping_dat <- xyt_dat %>% select(rat_num, frame, cluster)

# cleaning up
rm('xyt_dat')

# pivot such that rats are rows, frames are columns, and entries are cluster
grps_tibble <- grouping_dat %>%
  pivot_wider(names_from = frame, values_from = cluster)

# convert to a matrix
grps_matrix <- as.matrix(grps_tibble[,-1])
mat_dims <- dim(grps_matrix)
n_frames = mat_dims[2]

# get maximum integer group label for the `for()` loop below
max_grp_number <- max(grps_matrix)

# Initialize array for group member counts
member_counts <- array(0, dim=c(max_grp_number, n_frames))

# construct group label x frame array whose values are the number of 
# members in that group
for (i in 1:max_grp_number) {    # loop through the groups labels
  temp <- grps_matrix
  temp[temp != i] <- 0
  temp[temp == i] <- 1
  member_counts[i, ] <- colSums(temp) # number of members of this group for each frame
}

# Now perform run length encoding to get a data frame of group lengths (in frames)
# and group sizes (# of rats). NB: doing this in separate `for()` loop from 
# above simply for clarity.
full_grp_data <- tibble() # empty tibble to hold results
for (i in 1:max_grp_number) {    # loop through the groups labels
  # Perform the run-length encoding
  rle_output <- rle(member_counts[i, ])
  
  # Convert the RLE result to a temporaty tibble
  rle_tibble <- tibble(
    length = rle_output$lengths,
    value = rle_output$values,
    grp_label = i
  )
  
  # Append to the results
  full_grp_data <- bind_rows(full_grp_data, rle_tibble)
  
}

grp_data <- full_grp_data[full_grp_data$value != 0 ,]
