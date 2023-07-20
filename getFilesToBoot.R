library(rstudioapi) # for dialog box file selection
library(tidyverse)

# select directory via dialog...
dir_path <- selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = rstudioapi::getActiveProject()
)
# but this could also be hardcoded in a list or whatever.

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)

# count the files
n_files <- length(file_list)

# integers 1 to n_files
file_name_indexes <- seq(n_files)

# number files to select (on a bootstrap iteration, say)
n_needed_files <- 3

# set seed for reproducibility
set.seed(42)

# get random indexes without replacement (the default for `sample()`)
boot_file_indexes <- sample(file_name_indexes, n_needed_files)

# make a list of the chosen files for reading...
boot_file_list <- file_list[boot_file_indexes]

# create an empty data frame to hold the files' data
xyt_dat = data.frame()

# now read the files, tacking them on to xyt_dat as we go
for (i in 1:n_needed_files) {
  tmp <-  read_csv(boot_file_list[i], col_names = c("frame", "x", "y"), skip = 1)
  # add a rat ID column
  tmp <- tmp %>% 
    mutate(rat_num = i)
  xyt_dat <- rbind(xyt_dat, tmp)
}

# And `xyt_dat` now contains a bootstrapped data sample!