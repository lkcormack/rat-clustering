# summarize the combined bootstrapped data and plot with rat data

library(tidyverse)

######## load the needed summary files ########

file_path <- rstudioapi::selectFile(caption = "Select Real Data Summary File",
                                    filter = "RData Files (*.RData)",
                                    existing = TRUE)

load(file_path) # load real data summary file

rm(xyt_dat, rle_raw, cluster_dat) # remove unneeded dataframes

file_path <- rstudioapi::selectFile(caption = "Select Bootstrap Summary File",
                                    filter = "RData Files (*.RData)",
                                    existing = TRUE)

load(file_path) # load bootstrapped summary file

df <- rle_boot_all # rename for shorter code lines below
rm(rle_boot_all) # remove unneeded dataframe

######## Done loading files and cleaning up ########


######## Calculate bootstrap histogram values ########

# Get unique bootrep values
unique_bootreps <- unique(df$bootrep)

# Specify the histogram breaks 
value_breaks <-  seq(0, 16)
length_breaks <-  seq(0, 20, 0.2)

# Pre-allocate matrices to store histogram counts for each unique bootrep
# The number of rows is the number of unique bootreps and the number of columns is the number of breaks
values_hist_matrix <- matrix(nrow = length(unique_bootreps), 
                             ncol = length(value_breaks)-1)
rownames(values_hist_matrix) <- as.character(unique_bootreps)
lengths_hist_matrix <- matrix(nrow = length(unique_bootreps), 
                              ncol = length(length_breaks)-1)
rownames(lengths_hist_matrix) <- as.character(unique_bootreps)

# Loop over each unique bootrep and compute histograms, storing counts
# in matrices as we go
for (boot in unique_bootreps) {
  print(paste("On iteration", boot))
  
  # Subset the dataframe for the current bootrep
  subset_df <- df[df$bootrep == boot, ]
  
  # Calculate histogram for values
  values_hist <- hist(subset_df$values, 
                      breaks=value_breaks, 
                      plot=FALSE)
  
  # Calculate histogram for lengths
  lengths_hist <- hist(subset_df$lengths, 
                       breaks=length_breaks, 
                       plot=FALSE)
 
  # Store the counts in the matrices
  values_hist_matrix[boot, ] <- values_hist$counts
  lengths_hist_matrix[boot, ] <- lengths_hist$counts
  
} # end of bootstrap loop
######## Done calculating bootstrap histogram values ########

######## Compute the mean and standard deviation of the histograms ########

# Convert the means and sds to dataframes for plotting

######## PLOTTING ########