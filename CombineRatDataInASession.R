library(tidyverse)

# set directory path
dir_path <- "/path/to/directory/"

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)

# create a function to read csv file and add identifier column
read_csv_add_id <- function(file_path, id) {
  read_csv(file_path) %>% 
    mutate(frame_id = id)
}

# use purrr::map_df to apply function to each file in list and combine into one tibble
combined_data <- map_df(file_list, read_csv_add_id, .id = "file_id")

# rename columns to desired names
names(combined_data) <- c("file_id", "frame", "x", "y", "frame_id")

# view combined data
combined_data
