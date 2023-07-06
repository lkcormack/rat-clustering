# NB: THIS CODE CURRENTLY ASSUMES THAT THE DATAFRAME "xyt_dat" 
# EXISTS IN THE CURRENT ENVIRONMENT! 
# Sorry...

install.packages("plotly")
library(plotly)

## Plotting ##
n_frms_plt = 10000 # number of frames to plot
b_frms_plt = 1
e_frms_plt = b_frms_plt + n_frms_plt
z_range = c(xyt_dat$frame[b_frms_plt], xyt_dat$frame[e_frms_plt])

fig <- xyt_dat2 %>% 
  plot_ly(x = ~x, y = ~y, z = ~frame, color = ~rat_num,
          type = 'scatter3d', mode = 'lines', 
          colors = c("blue", "green", "red", "yellow", "magenta", "gold", "purple", 
                     "orange", "brown", "aquamarine", "darkblue", "darkgreen", "darkorange",
                     "darkred", "lightblue"),
          opacity = 0.2, 
          line = list(width = 3, opacity = 0.2)) %>% 
  layout(title = "Rats!",
         scene = list(
           xaxis = list(title = "x position"),
           yaxis = list(title = "y position"),
           zaxis = list(title = "video frame", range = z_range)
         ))

show(fig)
