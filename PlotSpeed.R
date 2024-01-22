# remake of plot speed

load("/Users/michaelpasala/Research/MovementLab/analysis/speeds/3all_speeds.Rda")

all_speeds$mean_speed <- rowMeans(all_speeds[, 1:3])
all_speeds <- all_speeds[, 4:6]

#result_subset <- subset(all_speeds, run == 1)[0:500, 2:3]
#colnames(result_subset)[colnames(result_subset) == "food"] <- paste0("food_", 1)


max <- 0
for (i in 1:15) {
  result_subset <- subset(all_speeds, run == i)
  l <- nrow(result_subset)
  if (l > max) {
    max <- l
  }
}

combined_df <- data.frame(
  base = rep(NA, max)
)


for (i in 1:15) {
  result_subset <- subset(all_speeds, run == i)[0:max, 2:3]
  colnames(result_subset)[colnames(result_subset) == "food"] <- paste0("food_", i)
  colnames(result_subset)[colnames(result_subset) == "mean_speed"] <- paste0("ms", i)
  combined_df <- cbind(combined_df, result_subset)
}

combined_df <- combined_df[-c(1)]


