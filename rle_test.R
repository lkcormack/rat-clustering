# Create a vector
x <- c(0, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1)

# Use rle to get lengths and values
run_info <- rle(x)

# The lengths of runs of 1s
high_lengths <- run_info$lengths[run_info$values == 1]

# The number of times the signal went high
high_times <- length(high_lengths)

print(paste("The signal went high", high_times, "times."))
print(paste("It stayed high for", toString(high_lengths), "times, respectively."))

# Get the locations where the signal went high
high_starts <- cumsum(run_info$lengths)[run_info$values == 1] - high_lengths + 1

print(paste("The signal went high at the following locations:", toString(high_starts)))
