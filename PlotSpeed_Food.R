# remake of plot speed
library(dplyr)
library(glue)

BIN = 100
MINUTES = 12
max <- MINUTES * 60 * 60 / BIN # all runs are truncated at a 12 min length 
bins_per_min = 3600 / BIN

cond <- 3

load(glue("/Users/michaelpasala/Research/MovementLab/analysis/speeds/{cond}all_speeds.Rda"))
#load("/Users/michaelpasala/Research/MovementLab/analysis/speeds/all_speed_old/all_speeds3.Rda")

all_speeds$mean_speed <- rowMeans(all_speeds[, 1:(length(all_speeds) - 2)])
all_speeds <- all_speeds[, (ncol(all_speeds) - 2):ncol(all_speeds)]
all_speeds$mean_speed[all_speeds$mean_speed == 0] <- NA

#result_subset <- subset(all_speeds, run == 1)[0:500, 2:3]
#colnames(result_subset)[colnames(result_subset) == "food"] <- paste0("food_", 1)


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

combined_df <- combined_df %>%
  select(-starts_with("food_"))


pre <- combined_df[0:(earliest_drop-1), ]
post <- combined_df[earliest_drop: max, ]

#pre <- combined_df

#pre <- pre %>%
#  select(-starts_with("food_"))

#post <- post %>%
#  select(-starts_with("food_"))

pre <- pre[rev(row.names(pre)), ]

############# new mean calc

pre_exp_minutes = ceiling(nrow(pre) / bins_per_min)
pre_minute_df <- data.frame(matrix(0, nrow = pre_exp_minutes, ncol = 1))

post_exp_minutes = ceiling(nrow(post) / bins_per_min)
post_minute_df <- data.frame(matrix(0, nrow = post_exp_minutes, ncol = 1))

for (i in 1:15) {
  
  add_pre <- c()
  add_post <- c()
  
  for (j in 1:(pre_exp_minutes) ) {
    #print( ((j - 1) * bins_per_min + 1) ) 
    #print( ((j - 1) * bins_per_min + 1) + bins_per_min - 1)
    temp <- pre[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), i] 
    #print("******")
    #print(temp)
    #print(mean(temp, na.rm = TRUE))
    add_pre <- c(add_pre, mean(temp, na.rm = TRUE))
  }
  
  for (j in 1:(post_exp_minutes) ) {
    #print( ((j - 1) * bins_per_min + 1) ) 
    #print( ((j - 1) * bins_per_min + 1) + bins_per_min - 1)
    temp2 <- post[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), i] 
    #print("******")
    #print(temp)
    #print(mean(temp, na.rm = TRUE))
    add_post <- c(add_post, mean(temp2, na.rm = TRUE))
  }

  pre_minute_df[i] <- add_pre
  post_minute_df[i] <- add_post
  
}

pre_minute_df <- t(pre_minute_df)
rownames(pre_minute_df) <- NULL

pre_names <- as.character(seq(-1, (-1 * ncol(pre_minute_df))), 1)
colnames(pre_minute_df) <- pre_names
pre_minute_df <- pre_minute_df[, as.character(seq((-1 * ncol(pre_minute_df)), -1))]


post_minute_df <- t(post_minute_df)
rownames(post_minute_df) <- NULL

post_names <- as.character(seq(0, ncol(post_minute_df) - 1), 1)
colnames(post_minute_df) <- post_names

final_df <- cbind(pre_minute_df, post_minute_df)

boxplot(final_df,
        ylim = c(0, 7),
        xlab = "Minutes",  # Customize the x-axis label
        ylab = "Mean Speed",  # Customize the y-axis label
        main = glue("Condition {cond}")  # Add a plot title
        #col = c("lightblue", "lightgreen", "lightpink")  # Specify box colors
)

save(final_df, file = glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))


############# load and trim data set values
library(glue)
cond <- 9
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))
keep <- as.character(seq(-5 ,5, 1))
final_df <- final_df[, keep]
save(final_df, file = glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))


############# graph data
cond <- 9
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))
boxplot(final_df,
        ylim = c(0, 7),
        xlab = "Minutes",  # Customize the x-axis label
        ylab = "Mean Speed",  # Customize the y-axis label
        main = glue("Condition {cond}")  # Add a plot title
        #col = c("lightblue", "lightgreen", "lightpink")  # Specify box colors
)

############# create anova friendly data
cond<-3
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))

anova <- data.frame(
  ID = c(NA),
  Food = c(NA),
  Time = c(NA),
  Condition = c(NA),
  Speed = c(NA)
)

for (i in 1:ncol(final_df)) {
  time <- as.integer(colnames(final_df)[i])
  for (j in 1:nrow(final_df)) {
    
    id <- paste0(j, "_", cond)
    food <- ifelse(time < 0, "pre", "post")
    condition <- cond
    speed <- final_df[[j, i]]
    
    anova <- rbind(anova, c(id, food, time, condition, speed))
  }
}

cond<-6
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))

for (i in 1:ncol(final_df)) {
  time <- as.integer(colnames(final_df)[i])
  for (j in 1:nrow(final_df)) {
    
    id <- paste0(j, "_", cond)
    food <- ifelse(time < 0, "pre", "post")
    condition <- cond
    speed <- final_df[[j, i]]
    
    anova <- rbind(anova, c(id, food, time, condition, speed))
  }
}


cond<-9
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))


for (i in 1:ncol(final_df)) {
  time <- as.integer(colnames(final_df)[i])
  for (j in 1:nrow(final_df)) {
    
    id <- paste0(j, "_", cond)
    food <- ifelse(time < 0, "pre", "post")
    condition <- cond
    speed <- final_df[[j, i]]
    
    anova <- rbind(anova, c(id, food, time, condition, speed))
  }
}

cond<-15
load(glue("/Users/michaelpasala/Research/MovementLab/plots/speed/new/{cond}_speed_minute.RData"))


for (i in 1:ncol(final_df)) {
  time <- as.integer(colnames(final_df)[i])
  for (j in 1:nrow(final_df)) {
    
    id <- paste0(j, "_", cond)
    food <- ifelse(time < 0, "pre", "post")
    condition <- cond
    speed <- final_df[[j, i]]
    
    anova <- rbind(anova, c(id, food, time, condition, speed))
  }
}

anova <- anova[-1, ]
save(anova, file = "/Users/michaelpasala/Research/MovementLab/plots/speed/new/anova.RData")
write.csv(anova, file = "/Users/michaelpasala/Research/MovementLab/plots/speed/new/anova.csv", row.names = FALSE)



############# old mean calc

#pre <- t(pre)
#post <- t(post)

#pre_mean <- data.frame(means = colMeans(pre, na.rm = TRUE))
#post_mean <- data.frame(means = colMeans(post, na.rm = TRUE))

#post_exp_minutes = nrow(post_mean) / bins_per_min

#pre_minute_df <- data.frame(matrix(0, nrow = bins_per_min, ncol = 1))
#post_minute_df <- data.frame(matrix(0, nrow = bins_per_min, ncol = 1))

#pre_exp_minutes = nrow(pre_mean) / bins_per_min
#for (j in 1:(pre_exp_minutes) ) {
#  #print( ((j - 1) * bins_per_min + 1) ) 
#  #print( ((j - 1) * bins_per_min + 1) + bins_per_min - 1)
#  temp <- pre_mean[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), ] 
#  pre_minute_df[j] <- temp
#}


#post_exp_minutes = nrow(post_mean) / bins_per_min
#for (j in 1:(post_exp_minutes) ) {
#  #print( ((j - 1) * bins_per_min + 1) ) 
#  #print( ((j - 1) * bins_per_min + 1) + bins_per_min - 1)
#  temp <- post_mean[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), ] 
#  post_minute_df[j] <- temp
#}

#pre_names <- as.character(seq((-1 * length(pre_minute_df)), -1), -1)
#colnames(pre_minute_df) <- pre_names

#post_names <- as.character(seq(0,(length(post_minute_df) - 1)) )
#colnames(post_minute_df) <- post_names

#all_minute_df <- cbind(pre_minute_df, post_minute_df)

#save(all_minute_df, file = glue("./{cond}_speed_minute.RData"))


#boxplot(all_minute_df,
#        ylim = c(0, 7),
#        xlab = "Minutes",  # Customize the x-axis label
#        ylab = "Mean Speed",  # Customize the y-axis label
#        main = glue("Condition {cond}")  # Add a plot title
#        #col = c("lightblue", "lightgreen", "lightpink")  # Specify box colors
#)
