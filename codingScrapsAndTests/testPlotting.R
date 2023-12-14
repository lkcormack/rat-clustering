aPlot <- results[results$frame == 32, ] %>%
ggplot(aes(x = x, y = y, color = as.factor(cluster))) + 
  geom_point()

show(aPlot)
