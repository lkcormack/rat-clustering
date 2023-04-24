library(ggplot2)

# load data
load('spaceTimeRats.RData')

# compute a tibble of frame vs. 
dist_df <- xyt_dat %>% 
  group_by(frame) %>%
  summarize(
    dist = max(dist(rbind(c(x[rat_num == "1"], y[rat_num == "1"]),
                           c(x[rat_num == "2"], y[rat_num == "2"]),
                           c(x[rat_num == "3"], x[rat_num == "3"])
                    ) # rbind
               ) # distance (Euclidean)
            ) # max of the three distances
    ) # summarize

# plot largest distance between any two rats
# note that thresholding on this number would be equivalent to
# saying all 3 rats were within a circle of that radius.

ggplot(dist_df, aes(x = frame, y = dist)) +  
  geom_point(size = 1, alpha = 0.1)           