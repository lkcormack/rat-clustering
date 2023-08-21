##### CombineRatDataInARun.R
# Takes all the data from a single "run" or recording, and combines
# them into a single data frame with a rat ID column.
# Need to convert to cm. Conversion is 7.0627 pixel/cm.

# to do: perhaps have a "raw" data frame and then another one 
# with NaNs removed for debugging/reality-checking
# like in PlotOneRatPath.R
# currently removes NaNs without apology or explanation.

library(tidyverse)
library(plotly)

save_flag = FALSE # save out the tibble with the cluster columns?
plot_flag = FALSE # make plot?

# Pick a run to look at (in my vocab, a "run" is single
# instance of recording rats running around in the box - 
# in other words, a single video recording)
dir_path <- rstudioapi::selectDirectory(caption = "Select Directory",
                                        label = "Select",
                                        path = rstudioapi::getActiveProject()
                                        )

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)
n_files <- length(file_list)
n_rats <- n_files # just for clarity of code below

# create an empty data frame
xyt_dat = data.frame()

# now read the files, tacking them on to xyt_dat as we go
for (i in 1:n_files) {
  tmp <-  read_csv(file_list[i], 
                   col_names = c("frame", "x", "y"), 
                   skip = 1,
                   show_col_types = FALSE)
  # add a rat ID column
  tmp <- tmp %>% 
    mutate(rat_num = i)
  xyt_dat <- rbind(xyt_dat, tmp)
}

# for sanity, get number of rows in orignial data before trimming NAs
tot_raw_obs <- dim(xyt_dat)[1] 

# Find the frames with NaNs in either data column
nan_frames = xyt_dat[is.na(xyt_dat$x) | is.na(xyt_dat$y), 'frame']

# Keep the frames that are *not* a member of nan_frames
# this will omit a rat's data for a given frame if one of its
# buddies has a NA on that frame, even if the first rat's data is valid...
# Which is what we need.
xyt_dat <- xyt_dat[!xyt_dat$frame %in% nan_frames$frame, ]

# fir sanity...
tot_valid_obs <- dim(xyt_dat)[1] 

# compute the frame jump column separately per rat
# these should end up identical for each rat
xyt_dat <- xyt_dat %>%
  group_by(rat_num) %>% 
  mutate(f_diff = c(1, diff(frame)))

##### some diagnostics
# useful numbers will be
# - frames (rows) per rat
# - total rows (all observations, including NAs)
# - above two should divide with no remainder
# - frames with NAs per rat
# - total number of NAs
# - final ligitimate number of observations
# - ligit obs should be total rows minus ... what?


# get total number of frames (per rat, i.e. unique frames)
tot_frames <- dim(tmp)[1] 
# test: total number of observations should = n_files (# of rats) x tot_frames
if (tot_raw_obs == n_rats * tot_frames) {
  print("File sizes / # of frames / observations sanity check passed!")
} else {
  print("File sizes / # of frames / observations not kosher...")
}

# get the number of frames with any NA vals (across rats)
nf <- nan_frames$frame # make vector for convenience
n_obs_omitted <- length(nf)
n_unique_NA_frames <- length(unique(nf))

# get total number of valid and omitted observations...
tot_valid_obs <- dim(xyt_dat)[1] 
n_omitted_obs <- n_rats * n_unique_NA_frames

if (tot_valid_obs == tot_raw_obs - n_rats * n_unique_NA_frames) {
  print("trimmed data / # of frames / observations sanity check passed!")
} else {
  print("trimmed data / # of frames / observations not kosher...")
}

######### End sanity checks ########

# make rat ID a factor (categorical variable)
xyt_dat$rat_num <- as.factor(xyt_dat$rat_num)

# write out the data. 
# For the automated version, build a filename
# based on the condition and run #
# format: [num rats/condition]r_r[run num]_merged.RData
##### Name and save the file #######
if (save_flag) {
  file_name <- file.choose(new = TRUE)
  file_name <- paste0(file_name, '.RData')
  save(xyt_dat, file = file_name)
}
##########

if (plot_flag) {
  n_frms_plt = 10000
  b_frms_plt = 1
  e_frms_plt = b_frms_plt + n_frms_plt
  z_range = c(xyt_dat$frame[b_frms_plt], xyt_dat$frame[e_frms_plt])

  fig <- xyt_dat %>%
    plot_ly(x = ~x, y = ~y, z = ~frame, color = ~rat_num,
            type = 'scatter3d', mode = 'lines',
            colors = c("blue", "green", "red"),
            opacity = 0.3,
            line = list(width = 6, opacity = 0.3)) %>%
    layout(title = "Rats!",
           scene = list(
             xaxis = list(title = "x position"),
             yaxis = list(title = "y position"),
             zaxis = list(title = "video frame", range = z_range)
             ))

  show(fig)
}


# reality checks
print(summary(xyt_dat))

## Plotting ##


