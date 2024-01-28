# load all data first with LoadAllSumData.R

par(asp = 1)

qqplot(n9Vals, n15Vals, xlab = "", ylab = "",
       cex = 3, pch = 16, col = "blue",
       axes = FALSE)

axis(side = 1, labels = FALSE)
axis(side = 2, labels = FALSE)