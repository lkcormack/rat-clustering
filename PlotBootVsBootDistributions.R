###### Plot real data and boot data overlaid #########
library(tidyverse)
# source("~/Documents/GitHub/rat-clustering/make_boot_hist.R")
source("/Users/michaelpasala/Research/MovementLab/rat-clustering/make_boot_hist.R")

TACC_flag <- 0 # set to 1 if running on TACC

if (TACC_flag) {
  n_reps <- 0; # this, passed to make_boot_hist(), will use all bootstrap reps
  plot_flag <- 0
} else {
  n_reps <- 40 # or whatever
  plot_flag <- 1
}

### Load files first! ####
## If the files are not in your working directory, you will need to 
## specify the path, or load the files "by hand" (and comment out the 
## load() lines below)

n_rats <- 3 # yes, this is hardcoded... could ask for input I suppose

# thresholding parameters
min_grp_size <- 3
min_grp_len <- 10

# load within rat data
# make filename
within_fname <- paste("/Users/michaelpasala/Research/Results/Within-50/", n_rats, 
               "RatsBootSummary.RData", sep = "")
print("Loading within-condition bootstrapping results... It'll be a minute...")
load(within_fname) # load data

# call make_boot_hist() function to compute histograms
within_summary <- make_boot_hist(rle_data_list, n_rats, 
                                 min_grp_size, min_grp_len,
                                 n_reps = n_reps)

# load big mama rat data
# make filename
mama_fname <- paste("/Users/michaelpasala/Research/Results/Mother-50/", n_rats, 
                      "MotherRatsBootSummary.RData", sep = "")
print("Loading mama bootstrapping results ...It'll be a minute...")
load(mama_fname) # load data

# call make_boot_hist() function to compute histograms
mama_summary <- make_boot_hist(rle_data_list, n_rats, 
                                 min_grp_size, min_grp_len,
                               n_reps = n_reps)

######### make stacked tibbles of the bootstrapped data #########
##### one for sizes and one for lifetimes #####
within_size_summary <- within_summary[[1]]
mama_size_summary <- mama_summary[[1]]

within_lifetime_summary <- within_summary[[2]]
mama_lifetime_summary <- mama_summary[[2]]

rm(within_summary, mama_summary) # remove the big lists of data to save memory

##### add a column to each tibble to indicate the group type #####
within_size_summary$group <- "within"
mama_size_summary$group <- "mama"
within_lifetime_summary$group <- "within"
mama_lifetime_summary$group <- "mama"

##### combine the tibbles #####
size_summary <- rbind(within_size_summary, mama_size_summary)
lifetime_summary <- rbind(within_lifetime_summary, mama_lifetime_summary)

rm(within_size_summary, mama_size_summary, within_lifetime_summary, 
   mama_lifetime_summary) # remove the big tibbles to save memory

################### PLOTTING ###############
if(plot_flag) { 
  title_str <- paste(n_rats, "Rats") # number of rats for figure titles
  ## (or make your own)
  
  dodge <- position_dodge(width = 0.1) # for dodging bars
  
  ##### Group sizes #####
  size_overlay <- ggplot() +
    geom_bar(data = size_summary,
             aes(x = size_mids, y = size_mean,fill = group),
             alpha = 0.5,
             stat="identity", position = dodge) +
    
    geom_errorbar(data = size_summary,
                  aes(x = size_mids, 
                      ymin = size_mean - size_sd, 
                      ymax = size_mean + size_sd,
                      group = group, color = group),
                  width = 0.25,  # Width of the error bars
                  position = dodge) +
    labs(y = "Counts", x = "Group Size", title = title_str) +
    theme_minimal()
  
  print(size_overlay)
  
  ##### Group lifetimes #####
  len_overlay <- ggplot() +
    geom_bar(data = lifetime_summary,
             aes(x = lifetm_mids, y = lifetm_mean,fill = group),
             alpha = 0.5,
             stat="identity", position = dodge) +
    
    geom_errorbar(data = lifetime_summary,
                  aes(x = lifetm_mids, 
                      ymin = lifetm_mean - lifetm_sd, 
                      ymax = lifetm_mean + lifetm_sd,
                      group = group, color = group),
                  width = 0.25,  # Width of the error bars
                  position = dodge) +
    xlim(0, 6) +
    labs(y = "Counts", x = "Group Lifetime (sec)", title = title_str) +
    theme_minimal() 
  
  print(len_overlay)
  
} # end if(plot_flag)

