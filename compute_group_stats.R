# compute block properties

library(tidyverse)

grps_matrix <- xyt_dat %>%
  pivot_wider(names_from = frame, values_from = group)

head(df_wide)

# convert to a matrix
df_matrix <- as.matrix(df_wide[,-1])


