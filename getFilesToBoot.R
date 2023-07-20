library(rstudioapi) # for dialog box file selection

dir_path <- selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = rstudioapi::getActiveProject()
)

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)

# count the files
n_files <- length(file_list)

file_name_indexes <- seq(n_files) # integers 1 to n_files

n_needed_files <- 3

set.seed(42)  # set seed for reproducibility
boot_file_indexes <- sample(file_name_indexes, n_needed_files)

boot_file_list <- file_list[boot_file_indexes]