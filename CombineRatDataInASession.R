# Takes all the data from a single "run" or recording, and combines
# them into a single data frame with a rat ID column.
# Need to convert to cm. Conversion is 7.0627 pixel/cm.

# to do: perhaps have a "raw" data frame and then another one 
# with NaNs removed for debugging/reality-checking
# like in PlotOneRatPath.R
# currently removes NaNs without apology or explanation.

library(tidyverse)
library(plotly)


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

# create an empty data frame
xyt_dat = data.frame()

# now read the files, tacking them on to xyt_dat as we go
for (i in 1:n_files) {
  tmp <-  read_csv(file_list[i], col_names = c("frame", "x", "y"), skip = 1)
  # add a rat ID column
  tmp <- tmp %>% 
    mutate(rat_num = i)
  xyt_dat <- rbind(xyt_dat, tmp)
}

# Find the frames with NaNs in either data column
nan_frames = xyt_dat[is.na(xyt_dat$x) | is.na(xyt_dat$y), 'frame']

# Keep the frames that are *not* a member of nan_frames
xyt_dat <- xyt_dat[!xyt_dat$frame %in% nan_frames$frame, ]

# compute the frame jump column separatly per rat
# these should end up identical for each rat
xyt_dat <- xyt_dat %>%
  group_by(rat_num) %>% 
  mutate(f_diff = c(1, diff(frame)))

# make rat ID a factor (categorical variable)
xyt_dat$rat_num <- as.factor(xyt_dat$rat_num)

# write out the data. 
# To do: make this a dialog. Or, better, just build a filename
# based on the condition and run #
save(xyt_dat, file = 'spaceTimeRats.RData')

# reality checks
print(summary(xyt_dat))

## Plotting ##
# n_frms_plt = 10000
# b_frms_plt = 1
# e_frms_plt = b_frms_plt + n_frms_plt
# z_range = c(xyt_dat$frame[b_frms_plt], xyt_dat$frame[e_frms_plt])
# 
# fig <- xyt_dat %>% 
#   plot_ly(x = ~x, y = ~y, z = ~frame, color = ~rat_num,
#           type = 'scatter3d', mode = 'lines', 
#           colors = c("blue", "green", "red"),
#           opacity = 0.3, 
#           line = list(width = 6, opacity = 0.3)) %>% 
#   layout(title = "Rats!",
#          scene = list(
#            xaxis = list(title = "x position"),
#            yaxis = list(title = "y position"),
#            zaxis = list(title = "video frame", range = z_range)
#            ))
# 
# show(fig)

