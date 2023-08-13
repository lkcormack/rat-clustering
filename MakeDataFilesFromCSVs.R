##### MakeDataFilesFromCSVs.Rw
# Make RData files per rat from .csv files
# This is a "needed only once" script to convert the 
# CSV files into appropriately formated data frames
# 
# This will hopefully speed up the main analysis programs
# profiling CombineRatDataInARun.R confirmed that the loading
# and saving takes a lot of time ...

library(tidyverse)
library(rstudioapi)

# Pick a Condition
dir_path <- selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = getActiveProject())

# get list of the directories (runs) in in this condition
dir_list <- list.dirs(path = dir_path, 
                      recursive = FALSE, 
                      full.names = TRUE)
n_runs <- length(dir_list)

# loop through the runs (directories) for this condition
for (i in 1:n_runs) {
  # get list of csv files in directory
  file_list <-
    list.files(path = dir_list[i],
               pattern = ".csv",
               full.names = TRUE)
  n_files <- length(file_list)
  
  # create an empty data frame
  xyt_dat = data.frame()
  
  # now read the files, tacking them on to xyt_dat as we go
  for (j in 1:n_files) {
    tmp <-
      read_csv(file_list[j],
               col_names = c("frame", "x", "y"),
               skip = 1)
    # add a rat ID column
    tmp <- tmp %>%
      mutate(rat_num = j)
    xyt_dat <- rbind(xyt_dat, tmp)
    
  } # end of looping through files in a run
  
  # construct a file name
  
  # save out the data frame
  
  
} # end of looping through runs!
