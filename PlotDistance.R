library(glue)
library(ggplot2)


cond <- 15
load(glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/{cond}all_distances.Rda"))

all_distance$Food <- factor(all_distance$Food, levels = c("pre-food", "post-food")) # scaling from pixel to cm

# saving

ggplot(all_distance, aes(x = Food, y = Mean_Distance)) +
  geom_boxplot() +
  labs(title = glue("Condition {cond}"),
       x = "Interval",
       y = "Distance (cm)") +
  # scale_y_continuous(limits = c(25000, 100000), breaks = seq(25000, 100000, by = 15000)) # nonscaled (pixel) graph
  scale_y_continuous(limits = c(350, 15000), breaks = seq(0, 15000, by = 2000)) # scaled (cm) graph


## organize distance data into anova format
cond <- 3
load(glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/{cond}all_distances.Rda"))
all_distance["Condition"] <- cond
anova_distance <- all_distance

cond <- 6
load(glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/{cond}all_distances.Rda"))
all_distance["Condition"] <- cond
anova_distance <- rbind(anova_distance, all_distance)

cond <- 9
load(glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/{cond}all_distances.Rda"))
all_distance["Condition"] <- cond
anova_distance <- rbind(anova_distance, all_distance)

cond <- 15
load(glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/{cond}all_distances.Rda"))
all_distance["Condition"] <- cond
anova_distance <- rbind(anova_distance, all_distance)

anova_distance$ID <- paste(anova_distance$Run, anova_distance$Condition, sep="_")

save(anova_distance, file = "/Users/michaelpasala/Research/MovementLab/analysis/distances/anova_distance.Rda")
write.csv(anova_distance, file = "/Users/michaelpasala/Research/MovementLab/analysis/distances/anova_distance.csv", row.names = FALSE)

pixel_per_cm <- 7.06
anova_distance_scaled <- read.csv("/Users/michaelpasala/Research/MovementLab/analysis/distances/anova_distance.csv")
anova_distance_scaled$Mean_Distance <- anova_distance_scaled$Mean_Distance/pixel_per_cm
write.csv(anova_distance_scaled, file=glue("/Users/michaelpasala/Research/MovementLab/analysis/distances/anova_distance_cm.csv"))
