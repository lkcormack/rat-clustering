# remake of plot speed
library(dplyr)

load("/Users/michaelpasala/Research/MovementLab/analysis/speeds/3all_speeds.Rda")

all_speeds$mean_speed <- rowMeans(all_speeds[, 1:3])
all_speeds <- all_speeds[, 4:6]
all_speeds$mean_speed[all_speeds$mean_speed == 0] <- NA

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

food_drops <- c()

for (i in 1:15) {
  result_subset <- subset(all_speeds, run == i)[0:max, 2:3]
  first_occurrence_index <- which(result_subset$food == 1)[1]
  food_drops <- c(food_drops, first_occurrence_index)
  
  colnames(result_subset)[colnames(result_subset) == "food"] <- paste0("food_", i)
  colnames(result_subset)[colnames(result_subset) == "mean_speed"] <- paste0("ms", i)
  combined_df <- cbind(combined_df, result_subset)
  
}

combined_df <- combined_df[-c(1)]

earliest_drop <- min(food_drops)
food_drop_diff <- food_drops - earliest_drop

shift <- function(x, n){
  c(x[-(seq(n))], rep(NA, n))
}

for (i in 1:15) {
  combined_df[[paste0("food_", i)]] <- shift(combined_df[[ paste0("food_", i)]], food_drop_diff[i])[0:max]
  combined_df[[paste0("ms", i)]] <- shift(combined_df[[paste0("ms", i)]], food_drop_diff[i])[0:max]
}

pre <- combined_df[0:(earliest_drop-1), ]
post <- combined_df[earliest_drop: max, ]

pre <- pre %>%
  select(-starts_with("food_"))

post <- post %>%
  select(-starts_with("food_"))

pre$mean <- rowMeans(pre, na.rm = TRUE)
post$mean <- rowMeans(post, na.rm = TRUE)

plot_data <- data.frame(
  minute = c(NA),
  mean_speed = c(NA),
)

curr_min <- c()
for (r in 1:nrows(pre)) {
  mod <- r %% 61
  if ( mod != 0) {
    # within a minute
    
  }
  
}
