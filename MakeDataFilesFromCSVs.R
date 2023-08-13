# Make RData files per rat from .csv files

library(tidyverse)

# Pick a run to look at (in my vocab, a "run" is single
# instance of recording rats running around in the box - 
# in other words, a single video recording)
dir_path <- rstudioapi::selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = rstudioapi::getActiveProject()
)

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)
n_files <- length(file_list)

# create an empty data frame
xyt_dat = data.frame()

# now read the files, tacking them on to xyt_dat as we go
for (i in 1:n_files) {
  tmp <-  read_csv(file_list[i], col_names = c("frame", "x", "y"), skip = 1)
  # add a rat ID column
  tmp <- tmp %>% 
    mutate(rat_num = i)
  xyt_dat <- rbind(xyt_dat, tmp)
}
