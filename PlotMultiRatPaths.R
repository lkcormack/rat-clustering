library(plotly)

# 

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