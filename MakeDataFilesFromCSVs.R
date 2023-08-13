##### MakeDataFilesFromCSVs.R
# Make RData files per rat from .csv files
# This is a "needed only once" script to convert the 
# CSV files into appropriately formatted data frames
# 
# This will hopefully speed up the main analysis programs
# profiling CombineRatDataInARun.R confirmed that the loading
# and saving takes a lot of time ...
#
# We'll save out a separate file for each rat rather than
# combining the in a run because this will be needed for
# the bootstrapping

library(tidyverse)
library(rstudioapi)

# file name strings
rat <- 'Rat'
run <- 'Run'
cond <- ''  # will fill this in when we have the number of rats
ext <- '.RData'

# Pick a Condition
dir_path <- selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = getActiveProject())

# get list of the directories (runs) in in this condition
dir_list <- list.dirs(path = dir_path, 
                      recursive = FALSE, 
                      full.names = TRUE)
n_runs <- length(dir_list) # should always be 15

# loop through the runs (directories) for this condition
for (i in 1:n_runs) {
  # get list of csv files in directory
  file_list <-
    list.files(path = dir_list[i],
               pattern = ".csv",
               full.names = TRUE)
  n_files <- length(file_list)
  
  # condition ID for the filename
  cond <- paste0('n_Rats', n_files)
  
  # create an empty data frame
  xyt_dat = data.frame()
  
  # now read the files, tacking them on to xyt_dat as we go
  for (j in 1:n_files) {
    xyt_dat <-
      read_csv(file_list[j],
               col_names = c("frame", "x", "y"),
               skip = 1,
               show_col_types = FALSE)
    # add a rat ID column
    xyt_dat <- xyt_dat %>%
      mutate(rat_num = j)
    
    # construct a file name
    file_name <- paste0(rat, j, run, i, cond, ext)
    full_name <- paste0(dir_list[i], "/", file_name)
    
    # save out the data frame
    save(xyt_dat, file = full_name)
    

  } # end of looping through files in a run
  
  
} # end of looping through runs!
