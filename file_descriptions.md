## Working file descriptions for the rat clustering code

Key parts will get incorporated to the README.md for the repo.

---

### Look at real rat data in steps

The following the files do a step-by-step analysis of a single run (recording) of the rat data

####  01CombineRatDataInARun.R

Takes all the data from a single "run" or recording, and combines them into a single data frame with a rat ID column.

#### 02DBScanClustering.R

This does the DBScan clustering, and outputs data in the same format as from the above step, except that it adds two columns:

* a “cluster” column that gives a cluster ID value for each rat on each frame
* a “seed” column that indicates whether a rat was in the interior of a cluster

#### 03ComputeGroupStats.R

This does the run length encoding (RLE) to determine group sizes and group lengths. It outputs a tibble containing columns with the group sizes (“values”), group lifetimes (“lengths”), and group IDs (“grp_label” – prob. not that useful here).

Saves data out as a `cluster_lengths_sizes` tibble that has exactly what it says in it. Has some incomplete aspirational plotting code in it also too.

### Look at real data in one go

#### AnalyzeGroupsInCondition.R

This combines the steps above into one script. The one caveat being that you have to convert the .csv data files to .RData files first using `MakeDataFilesFromCSVs.R` to make the loading faster. Has actual useful plotting (unlike `03ComputeGroupStats.R`). But, mainly, it outputs a `cluster_lengths_sizes` tibble for the actual rat data.

* **MakeDataFilesFromCSVs.R** – converts .csv files into .RData files

---

### Bootstrapping analysis

Two basic bootstrapping analyses were run. In the first, a simulation of a 3 rat run, for example, consisted only of trajectories from rats that were run in a 3 rat condition. In the other (the “mother” bootstrap), a simulation of a 3 rat run, for example, could consist of trajectories from rats that were run in any condition (3, 6, 9, or 15 rats). The idea here was to see if there were grouping differences based solely on how rats moved with different numbers of rats in the environment, independent of any particular social behavior of one rat reacting to the presence of another.

---

### Core bootstrapping

Both of the following scripts create and save lists, each element of which is the output of the RLE analysis for a bootstrap replication; the group sizes and lifetimes for that bootstrap replication.

#### BootAnalyzeGroupsInCondition.R

This is the main file that chews through the original data, and constructs bootstrap replicates based on actual rat trajectories, but that we’re not from the same actual run (recording). In other words, each “rat” in the bootstrap run could not have adjusted its behavior based on the other “rats” in the bootstrapped trial. The rats were, in effect, ghost rats that could not see, smell, or feel one another.

In this version, all rat trajectories come from the same condition. In other words, for a “3 rats” bootstrap run, all rat trajectories came from rats that ran with only 2 other rats.

It outputs a series of lists (one list for each bootstrap replication), where each list is a tibble of group sizes and lengths like the output of `AnalyzeGroupsInCondition.R` for the actual data.

#### BootMotherAnalyzeGroupsInCond.R

Same as above, except that a rat in a “3 rat” bootstrap replicate could have come from a 15 rat condition, i.e. might have been actually in the box with 14 other rats.

### Summarizing and plotting the results

Takes the output of the RLE analysis from the above code, computes histogram data (bins, counts) and plots the results. for the bootstrapping data, it plots the mean counts in each bin with error bars showing the standard deviations across bootstrap replications (i.e., the estimated standard errors).

#### PlotRealAndBootSummary.R

This takes the `cluster_lengths_sizes` from a actual rat data file, and a corresponding `rle_data_list` from the bootstrapping, each of which contains a tibble analogous to the `cluster_lengths_sizes` tibble from the experimental data, and then plots a histogram of the real data and the average histogram of the bootstrapping data (averaged across bootstrap replications). 

NB: should modify to call `make_boot_hist.R` to be consistent and modular.

#### PlotBootVsBootDistributions.R

Computes and plots the histograms for the within-condition vs. “mother” bootstrapping findings. In other words, bootstrapping an *n* rats condition using only only rats that were run in that condition vs. sampling from rats that were run in any condition. (So a 6 rat condition might be simulated from 6 trajectories from any of 3, 6, 9, and/or 15 experimental conditions).

##### make_boot_hist.R

Called to compute the histogram values by the above script (and should be by the script before that).

