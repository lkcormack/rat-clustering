###### Plotting routines for rat clustering summary data #########
library(tidyverse)

### Load a summary file first! ####

title_str <- paste(max(cluster_dat$rat_num), "Rats") # number of rats for figure titles

# make a dataframe of cluster lengths (in sec) and sizes over length
# threshold for plotting
len_thresh <- 10 # threshold for length (in frames) of a "real" cluster
thresh_lengths_sizes <- cluster_lengths_sizes[cluster_lengths_sizes$lengths > len_thresh, ]
thresh_lengths_sizes$lengths <- (thresh_lengths_sizes$lengths)/60 # convert to seconds

###### Actual Plotting ######
# Set font sizes and such
tickFontSize <- 16
titleFontSize <- 20
xlabFontSize <- 20
xlabTxt = ""
ylabTxt = ""


# plot lifetimes vs. cluster size
p <- thresh_lengths_sizes %>% 
  ggplot(aes(x = values, y =  lengths)) + 
  geom_jitter(width = 0.2, height = 0, color = "blue", alpha = 0.2) +
  ggtitle(title_str) + 
  xlim(3, 15) +
  ylim(0, 10) +
  xlab(xlabTxt) +
  ylab(xlabTxt) +
  theme(axis.text.x = element_text(size = tickFontSize),  
        axis.text.y = element_text(size = tickFontSize)) + 
  #theme(axis.text.x = element_blank()) + # no x labels - comment out for bottom panel
  ggtitle(title_str) +
  theme(plot.title = element_text(size = titleFontSize))
show(p)

logp <- p + scale_y_log10()
show(logp)