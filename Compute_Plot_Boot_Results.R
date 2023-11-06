# summarize the combined bootsrapped data

library(tidyverse)

# load the file...
# load it by hand for now

df <- rle_boot_all

# Get unique bootrep values
unique_bootreps <- unique(df$bootrep)

# Specify the number of breaks 
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

# Loop over each unique bootrep
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
  
}

# Convert the matrices to dataframes