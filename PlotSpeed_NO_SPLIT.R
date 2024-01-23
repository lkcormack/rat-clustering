library(tidyverse)
library(fpc)
library(rstudioapi)
library(dplyr)
library(tidyr)
library(glue)

# constants
BIN = 100
MINUTES = 12
max_row <- MINUTES * 60 * 60 / BIN # all runs are truncated at a 12 min length 
bins_per_min = 3600 / BIN

# plot 15 box plots where each box plot represents a 1 minute bin of the video
# each point 'n' that is in 1 box plot is the avg speed found of all rats in run 'n' at time (bin) 't'
cond <- 3
dir_path <- glue('/Users/michaelpasala/Research/MovementLab/analysis/speeds/{cond}')

# load data
data_path <- paste(dir_path, "all_speeds.Rda", sep="")
load(data_path)
if (anyNA(all_speeds)) {
  stop("NA's found upon loading")
}

all_speeds <- all_speeds[-c(5)]

# get rat_nums
rat_nums <- unique(all_speeds$run)

# get the avg of each bin

all_speeds$mean <- rowMeans(all_speeds[ , 1:(length(all_speeds) - 1)])
mean_df <- all_speeds[,(ncol(all_speeds) - 1):ncol(all_speeds)]
mean_df$mean[mean_df$mean == 0] <- NA

# create df where each column is a run (15 columns)
lateral_df <- data.frame(matrix(0, nrow = max_row, ncol = 1))
for (i in 1:length(rat_nums)) {
  single_df <- mean_df[mean_df$run == i,]
  single_df <- single_df[1:max_row, ]
  lateral_df <- cbind(lateral_df, single_df$mean)
}
lateral_df <- lateral_df[ , 2:length(lateral_df)]
lateral_df <- t(lateral_df)

# take 
mean_df <- data.frame(means = colMeans(lateral_df, na.rm = TRUE))
exp_minutes = nrow(mean_df) / bins_per_min

minute_df <- data.frame(matrix(0, nrow = bins_per_min, ncol = 1))

for (j in 1:exp_minutes ) {
  #print( ((j - 1) * bins_per_min + 1) ) 
  #print( ((j - 1) * bins_per_min + 1) + bins_per_min - 1)
  temp <- mean_df[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), ] 
  minute_df[j] <- temp
}

names <- as.character(seq(1,length(minute_df)))
colnames(minute_df) <- names

boxplot(minute_df,
        ylim = c(0, 7),
        xlab = "Minutes",  # Customize the x-axis label
        ylab = "Median Speed",  # Customize the y-axis label
        main = glue("Condition {cond}")  # Add a plot title
        #col = c("lightblue", "lightgreen", "lightpink")  # Specify box colors
)


plot_speed_over_minutes <- function (condition) {
  cond <- condition
  dir_path <- glue('/Users/michaelpasala/Research/MovementLab/analysis/speeds/{cond}')
  
  # load data
  data_path <- paste(dir_path, "all_speeds.Rda", sep="")
  load(data_path)
  if (anyNA(all_speeds)) {
    stop("NA's found upon loading")
  }
  
  # get rat_nums
  rat_nums <- unique(all_speeds$run)
  
  # get the avg of each bin
  all_speeds$mean <- rowMeans(all_speeds[ , 1:length(all_speeds) - 1])
  mean_df <- all_speeds[,(ncol(all_speeds) - 1):ncol(all_speeds)]
  
  # create df where each column is a run (15 columns)
  lateral_df <- data.frame(matrix(0, nrow = max_row, ncol = 1))
  for (i in 1:length(rat_nums)) {
    single_df <- mean_df[mean_df$run == i,]
    single_df <- single_df[1:max_row, ]
    lateral_df <- cbind(lateral_df, single_df$mean)
  }
  lateral_df <- lateral_df[ , 2:length(lateral_df)]
  lateral_df <- t(lateral_df)
  
  # take 
  mean_df <- data.frame(means = colMeans(lateral_df, na.rm = TRUE))
  exp_minutes = nrow(mean_df) / bins_per_min
  
  minute_df <- data.frame(matrix(0, nrow = bins_per_min, ncol = 1))
  
  for (j in 1:exp_minutes ) {
    temp <- mean_df[((j - 1) * bins_per_min + 1):(((j - 1) * bins_per_min + 1) + bins_per_min - 1), ] 
    minute_df[j] <- temp
  }
  
  names <- as.character(seq(1,length(minute_df)))
  colnames(minute_df) <- names
  
  boxplot(minute_df,
          ylim = c(0, 7),
          xlab = "Minutes",  # Customize the x-axis label
          ylab = "Median Speed",  # Customize the y-axis label
          main = glue("Condition {cond}")  # Add a plot title
          #col = c("lightblue", "lightgreen", "lightpink")  # Specify box colors
  )
  return(NaN)
  
}


# plot every bin at time 't' as a bar on a bar chart
# each point 'n' that averages to make 1 bar at time 't' is the avg speed found of all rats in run 'n' at time (bin) 't'
# therefore, there are always 15 points that average to make 1 bar
plot_speed_over_all_bins <- function (condition) {
  cond <- condition
  dir_path <- glue('/Users/michaelpasala/Research/MovementLab/dataR/{cond}Rats')
  
  # load data
  data_path <- paste(dir_path, "all_speeds.Rda", sep="/")
  load(data_path)
  if (anyNA(all_speeds)) {
    stop("NA's found upon loading")
  }
  
  # get rat_nums
  rat_nums <- unique(all_speeds$run)
  print(rat_nums)
  print(length((rat_nums)))
  
  
  all_speeds$mean <- rowMeans(all_speeds[ , 1:length(all_speeds) - 1])
  mean_df <- all_speeds[,(ncol(all_speeds) - 1):ncol(all_speeds)]
  
  lateral_df <- data.frame(matrix(0, nrow = max_row, ncol = 1))
  ## we are basing it off the min
  for (i in 1:length(rat_nums)) {
    single_df <- mean_df[mean_df$run == i,]
    single_df <- single_df[1:max_row, ]
    lateral_df <- cbind(lateral_df, single_df$mean)
  }
  
  lateral_df <- lateral_df[ , 2:length(lateral_df)]
  lateral_df <- t(lateral_df)
  
  means <- colMeans(lateral_df, na.rm = TRUE)
  labels <- seq(1, length(means))
  histogram_df <- data.frame(mean_speed = means, bin_num = labels)
  
  histogram_df$bin_num <- factor(histogram_df$bin_num, levels = labels)
  #histogram_df$bin_num <- as.character(histogram_df$bin_num)
  
  actual_labels = seq(from = 10, to = max_row, by = 10)
  
  ggplot(histogram_df, aes(x=bin_num, y=mean_speed)) + 
    geom_bar(stat = "identity") +
    scale_x_discrete(breaks = actual_labels) +
    labs(
      title = glue("Condition {cond}"),
      x = "Bin Number",
      y = "Mean Speed"
    ) +
    theme(plot.title = element_text(hjust = 0.5)) +
    scale_y_continuous(limits = c(0, 7), breaks = seq(0, 7, by = 1))
  
}


plot_speed_over_minutes(15)

