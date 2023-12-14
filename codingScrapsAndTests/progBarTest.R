# progress bar test

# Install and load the progress package
if (!require(progress)) {
  install.packages("progress")
}
library(progress)

# Define the total number of iterations
n <- 100

# Create a progress bar object
pb <- progress_bar$new(total = n)

# Loop with progress bar
for (i in 1:n) {
  # Your code here...
  Sys.sleep(0.01)  # Sleep to slow down the loop for demonstration purposes
  
  # Update the progress bar
  pb$tick()
}
