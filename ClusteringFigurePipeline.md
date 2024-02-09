## 0. Convert raw data .csv files to .RData files  - MakeDataFilesFromCSVs.R

This script simply converts the original CSV files into native RData files for faster loading.



## 1. Make summary data files – AnalyzeGroupsInCondition.R

This script makes the summary data files from each condition. I does

* the DBScan clustering
* the Run Length encoding 

It then does some *optional* plotting, and, importantly, ***saves the summary file for that condition***.

This summary file (e.g. “3RatsClusterSummary.RData”) are used for all subsequent analysis and plotting for the clustering data.

