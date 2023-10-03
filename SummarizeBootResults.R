# Analyze bootstrapping RLE results

# load rle_data_list
load("3RatsBootSummary.RData")

# get number of bootstrap replications
n_reps <- length(rle_data_list)

for (i in 1:n_reps) {
  rle_temp <- rle_data_list[[i]]
  
  ####### below are temp placeholders #####
  title_str <- paste(max(cluster_dat$rat_num), "Rats") # number of rats for figure titles
  ## (or make your own)
  
  # histograms of cluster lifetimes
  len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
  plt_lengths <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
  plt_lengths$lengths <- (plt_lengths$lengths)/60 # convert to seconds
  
  ###### make and save a histogram object #####
  trimmed_plt_lens <-  plt_lengths$lengths[plt_lengths$lengths < 6]
  LfTmHist <- hist(trimmed_plt_lens, 
                   breaks = seq(0, 6, 0.2), 
                   freq = FALSE,
                   ylim = c(0, 2.5))
  
}