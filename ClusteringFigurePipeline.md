## 0. Convert raw data .csv files to .RData files  - [MakeDataFilesFromCSVs.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/AnalyzeGroupsInCondition.R)

This script simply converts the original CSV files into native RData files for faster loading.



## 1. Make summary data files – [AnalyzeGroupsInCondition.R](/Users/lkcormack/Library/CloudStorage/Box-Box/MovementAnalysisMS/ClusteringAnalysisCode/AnalyzeGroupsInCondition.R)

This script makes the summary data files from each condition. It does

* the DBScan clustering
* the Run Length encoding 

It then does some *optional* plotting, and, importantly, ***saves the summary file for that condition***.

These summary files (e.g. “*3RatsClusterSummary.RData*”) are used for all subsequent analysis and plotting for the clustering data.



## 2. Plot Histograms of the actual cluster sizes and durations -  [PlotRealHistsWithSEs.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/PlotRealHistsWithSEs.R) 

This script plots the histograms of the actual data for both cluster sizes and durations with error bars showing ± 1 standard error of the mean across the 15 runs in each condition. 

A summary file (e.g. “3RatsClusterSummary.RData”), must be loaded prior to running the script!

## 3. Plot duration and log(duration) vs. cluster size - [PlotDurVsClustSize.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/PlotDurVsClustSize copy.R)

This script plots cluster lifetime and log(cluster lifetime) vs. cluster size. 

A summary file (e.g. “3RatsClusterSummary.RData”), must be loaded prior to running the script!

## 4. Compute the summary statistics for both lifetime and size distributions for a condition - [Comp_Summary_Stats.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/Comp_Summary_Stats.R)

Computes the mean, sd (se of the mean), and skew for the loaded summary file (e.g. “3RatsClusterSummary.RData”). The means and SEs are hardcoded into [makeNratMeansPlots.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/makeNratMeansPlots.R) for plotting. The summary data (the outputs of this file for each condition) are in [DistributionStats.xlsx](Box/MovementAnalysisMS/DistributionStats.xlsx).

## 5. Make pairwise quantile - quantile plots for all conditions - [MakeQQPlots.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/MakeQQPlots.R)

Makes a QQ plot of a pair of cluster size or cluster lifetime distribution. You must 

* run [LoadAllSumData.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/LoadAllSumData.R) first to load the summary data and create the necessary variables
* enter the variable names corresponding to the distributions you wish to plot, e.g. ‘qqplot(n9Vals, n15Vals,…’

## 6. Plot mean cluster lifetime and size vs. number of rats in the enclosure -[makeNratMeansPlots.R](Box/MovementAnalysisMS/ClusteringAnalysisCode/makeNratMeansPlots.R)

Plots the 

* mean cluster size ± 1 SE vs. number of rats 
* mean cluster duration vs. number rats
* log(duration) vs. log(number of rats)
* does a (first order) linear regression for all of the above

It also (optionally) does the same for the bootstrapped distributions.



