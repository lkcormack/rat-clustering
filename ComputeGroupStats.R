# compute block properties

library(tidyverse)

save_flag = FALSE # save out the rle results?
plot_flag = TRUE # make plot?

file_path <- rstudioapi::selectFile(caption = "Select RData File",
                                    filter = "RData Files (*.RData)",
                                    existing = TRUE)

load(file_path)

# make data frame without unneeded columns
cluster_dat <- xyt_dat %>% select(rat_num, frame, cluster)
# rat number cycles fast, frame cycles slowly

# remove unneeded Big Kahuna data frame
rm('xyt_dat')

# pivot such that rats are rows, frames are columns, and entries are cluster
# this will allow us to detect frame-to-frame continuity of clusters more
# easily
grps_tibble <- cluster_dat %>%
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
  temp <- grps_matrix    # make a matrix whose entries are
  temp[temp == i] <- 1   # 1 for this group and
  temp[temp != i] <- 0.  # 0 for the other groups
  member_counts[i, ] <- colSums(temp) # number of members of this group for each frame
}
# We now have a matrix indicating whether a group (row) is present
# on a given frame (column)

# Now perform run length encoding (rle) to get a data frame of group lengths 
# (in frames) and group sizes (# of rats).   
# NB: doing this in separate `for()` loop from above for clarity.
rle_raw <- tibble() # empty tibble to hold results
for (i in 1:max_grp_number) {    # loop through the groups labels
  # Perform the run-length encoding for this row
  rle_output <- rle(member_counts[i, ])
  
  # the output of rle() is a list, so
  # convert the RLE result to a temporary tibble
  rle_tibble <- tibble(
    lengths = rle_output$lengths,
    values = rle_output$values,
    grp_label = i
  )
  
  # Append to the results to the main output tibble
  rle_raw <- bind_rows(rle_raw, rle_tibble)
  
}

# need to add a cumulative sum column of the lengths
# to code the frame number at which clusters start
rle_with_frames <- rle_raw %>% 
  group_by(grp_label) %>% 
  mutate(frame_num = cumsum(lengths))

# Runs of zeros are runs of "no cluster" for that cluster ID
# So eliminate runs of zeros.
cluster_lengths_sizes <- rle_raw[rle_raw$values != 0, ]

# save...
##### Name and save the file #######
if (save_flag) {
  file_name <- file.choose(new = TRUE)
  file_name <- paste0(file_name, '.RData')
  save(cluster_lengths_sizes, file = file_name)
}
##########

##### optional plotting #####
if (plot_flag) {
  
  len_thresh <- 10
  t <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]

  # plot of some sort
  clstr_len_plot <- t %>%
    ggplot(aes(x = lengths)) +
    geom_histogram(bins = 30, alpha = 0.5)
  
  show(clstr_len_plot)
}
#####