library(tidyverse)

# load data created by CombineRatDataInASession.R
load('spaceTimeRats.RData')

# compute a tibble of frame vs. max. distance
dist_df <- xyt_dat %>% 
  group_by(frame) %>%
  summarize(
    max_dist = max(dist(rbind(c(x[rat_num == "1"], y[rat_num == "1"]),
                           c(x[rat_num == "2"], y[rat_num == "2"]),
                           c(x[rat_num == "3"], x[rat_num == "3"])
                    ) # rbind
               ) # distance (Euclidean)
            ) # max of the three distances
    ) # summarize


# note that thresholding on this number is equivalent to
# saying all 3 rats were within a vesca piscis; the intersection
# of two circles around two rats of that diameter
thresh = 300 # 

dist_df <- dist_df %>% 
  mutate(cluster = max_dist < thresh)

# plot largest distance between any two rats of the three
dist_plot <- ggplot(dist_df, aes(x = frame, y = dist, color = cluster)) +  
  geom_point(size = 1, alpha = 0.3)           
show(dist_plot)