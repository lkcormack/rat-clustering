

set.seed(42)  # For reproducibility

# Create the dataframe
df <- data.frame(
  col1 = rnorm(10),  # 10 random numbers from a standard normal distribution
  col2 = rnorm(10),
  col3 = rnorm(10)
)

# Insert some NaNs in columns 2 and 3
df$col2[sample(1:10, 3)] <- NaN  # Insert 3 NaNs in col2
df$col3[sample(1:10, 4)] <- NaN  # Insert 4 NaNs in col3

# Print the dataframe
print(df)

c <- df[complete.cases(df$col2, df$col3), ]
print(c)