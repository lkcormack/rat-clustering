library(tidyverse)

# Install and load ggplot2 if not already installed
# install.packages("ggplot2")
library(ggplot2)


### Plotting violin plots of total approaches 

data <- read.csv("/Users/michaelpasala/Research/MovementLab/analysis/approaches/all_approaches_old.csv")

data <- data[ -c(1) ]

# Create a violin plot
ggplot(data, aes(x = Condition, y = Approaches, group = Condition)) +
  geom_violin(fill = "skyblue", color = "black", alpha = 0.7) +
  stat_summary(fun=mean, geom="point", shape=8, size=2, color="black") +
  geom_smooth(method="lm", se=FALSE, color="black", linewidth=0.5, aes(group = 1)) +
  labs(title = "Approaches Across Conditions",
       x = "Number of Rats",
       y = "Total number of Approaches") +
  scale_x_continuous(breaks = c(3, 6, 9, 12, 15), labels = c("3", "6", "9", "12", "15"))


### Plotting violin plots of mean approaches

data$Approaches <- data$Approaches / data$Condition # get the mean approaches per rat

# Create a violin plot
ggplot(data, aes(x = Condition, y = Approaches, group = Condition)) +
  geom_violin(fill = "firebrick", color = "black", alpha = 0.7) +
  stat_summary(fun=mean, geom="point", shape=8, size=2, color="black") +
  geom_smooth(method="lm", se=FALSE, color="black", linewidth=0.5, aes(group = 1)) +
  labs(title = "Approaches Across Conditions",
       x = "Number of Rats",
       y = "Mean Approaches per Rat") +
  scale_x_continuous(breaks = c(3, 6, 9, 12, 15), labels = c("3", "6", "9", "12", "15"))




### Plotting boxplots of approaches for each condition split by food

data <- read.csv("/Users/michaelpasala/Research/MovementLab/analysis/approaches/all_approaches.csv")

data <- data[ -c(1) ]

data$Food <- factor(data$Food, levels= c("pre", "post"))

ggplot(data, aes(x = Condition, y = Approaches, fill = Food, group = Condition)) +
  geom_boxplot() +
  stat_summary(fun=mean, geom="point", shape=8, size=2, color="black") +
  geom_smooth(method="lm", se=FALSE, aes(group=Food), linewidth=0.5, color="black", ymax=5000) +
  facet_wrap(~ Food) +
  labs(title = "Total Approaches as a Function of Number of Rats",
       x = "Condition",
       y = "Approaches") +
  scale_x_continuous(breaks = c(3, 6, 9, 12, 15), labels = c("3", "6", "9", "12", "15"))

