library(tidyverse)
library(ggplot2)
library(glue)
install.packages("stringr")


#n_rats <- 15
type <- "Within"

### e.g. load("6RatsClusterSummary.RData")
#load("15RatsClusterSummary.RData")
#load(paste0("/Users/michaelpasala/Research/Results/Cluster/", n_rats, "RatsClusterSummary.RData")) # michael's dirs

# load boot rle_data_list
#load("15RatsBootSummary.RData")
#load(paste0(glue("/Users/michaelpasala/Research/Results/{type}/"), n_rats, "RatsBootSummary.RData")) # michael's dirs

files <- list.files(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/"))

cols <- c("size_mids", "size_mean", "size_sd", "group", "condition")
all_within_data <- data.frame(
  matrix(ncol = length(cols), nrow = 0)
)
colnames(all_within_data) <- cols


for (i in 1:length(files)) {
  if (endsWith(files[i], "size_plot.csv")) {
    n_rats <- strsplit(files[i], "_")[[1]][1]
    print(n_rats)
    name <- files[i]
    data <- read.csv(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/{name}"))
    data$group <- n_rats
    data$condition <- type
    data$n_obs <- NULL
    print(files[i])
    all_within_data <- rbind(all_within_data, data)
  }
}


type <- "Mother"

### e.g. load("6RatsClusterSummary.RData")
#load("15RatsClusterSummary.RData")
#load(paste0("/Users/michaelpasala/Research/Results/Cluster/", n_rats, "RatsClusterSummary.RData")) # michael's dirs

# load boot rle_data_list
#load("15RatsBootSummary.RData")
#load(paste0(glue("/Users/michaelpasala/Research/Results/{type}/"), n_rats, "RatsBootSummary.RData")) # michael's dirs

files <- list.files(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/"))

cols <- c("size_mids", "size_mean", "size_sd", "group", "condition")
all_mother_data <- data.frame(
  matrix(ncol = length(cols), nrow = 0)
)
colnames(all_mother_data) <- cols


for (i in 1:length(files)) {
  if (endsWith(files[i], "size_plot.csv")) {
    n_rats <- strsplit(files[i], "_")[[1]][1]
    print(n_rats)
    name <- files[i]
    data <- read.csv(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/{name}"))
    data$group <- n_rats
    data$condition <- type
    data$n_obs <- NULL
    print(files[i])
    all_mother_data <- rbind(all_mother_data, data)
  }
}


type <- "Real"

### e.g. load("6RatsClusterSummary.RData")
#load("15RatsClusterSummary.RData")
#load(paste0("/Users/michaelpasala/Research/Results/Cluster/", n_rats, "RatsClusterSummary.RData")) # michael's dirs

# load boot rle_data_list
#load("15RatsBootSummary.RData")
#load(paste0(glue("/Users/michaelpasala/Research/Results/{type}/"), n_rats, "RatsBootSummary.RData")) # michael's dirs

files <- list.files(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/"))

cols <- c("size_mids", "size_mean", "size_sd", "group", "condition")
all_real_data <- data.frame(
  matrix(ncol = length(cols), nrow = 0)
)
colnames(all_real_data) <- cols


for (i in 1:length(files)) {
  if (endsWith(files[i], "size_plot.csv")) {
    n_rats <- strsplit(files[i], "_")[[1]][1]
    print(n_rats)
    name <- files[i]
    data <- read.csv(glue("/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/{type}/{name}"))
    
    data$group <- n_rats
    data$condition <- type
    data$n_obs <- NULL
    colnames(data) <- cols
    print(files[i])
    all_real_data <- rbind(all_real_data, data)
  }
}


all_data_cluster_size <- rbind(all_real_data, all_within_data)
all_data_cluster_size <- rbind(all_data_cluster_size, all_mother_data)


write.csv(all_data_cluster_size, file="/Users/michaelpasala/Research/MovementLab/plots/RealAndBoot/cluster_size_anova.csv")


