library(tidyverse)

# set directory path
dir_path <- "./data/3Rats/Average_Position_01"

# get list of csv files in directory
file_list <- list.files(path = dir_path, pattern = ".csv", full.names = TRUE)
n_files <- length(file_list)

xyt_dat = data.frame()

# now read the files, tacking them on as we go
for (i in 1:n_files) {
  tmp <-  read_csv(file_list[i], col_names = c("frame", "x", "y"), skip = 1)
  tmp <- tmp %>% 
    #filter(!is.na(x) & !is.na(y)) %>% 
    mutate(rat_num = i)
  xyt_dat <- rbind(xyt_dat, tmp)
}

nan_frames = xyt_dat[is.na(xyt_dat$x) & is.na(xyt_dat$y), 'frame']

xyt_dat <- xyt_dat[!xyt_dat$frame %in% nan_frames$frame, ]

xyt_dat <- xyt_dat %>%
  mutate(f_diff = c(1, diff(frame)))

xyt_dat$rat_num <- as.factor(xyt_dat$rat_num)
  
save(xyt_dat, file = 'spaceTimeRats.RData')

## Plotting ##
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

