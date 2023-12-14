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

### Look at real data in one go

#### AnalyzeGroupsInCondition.R

This combines the steps above into one script. The one caveat being that you have to convert the .csv data files to .RData files first using `MakeDataFilesFromCSVs.R` to make the loading faster.

* **MakeDataFilesFromCSVs.R** – converts .csv files into .RData files

---

### Bootstrapping analysis

Two basic bootstrapping analyses were run. In the first, a simulation of a 3 rat run, for example, consisted only of trajectories from rats that were run in a 3 rat condition. In the other (the “mother” bootstrap), a simulation of a 3 rat run, for example, could consist of trajectories from rats that were run in any condition (3, 6, 9, or 15 rats). The idea here was to see if there were grouping differences based solely on how rats moved with different numbers of rats in the environment, independent of any particular social behavior of one rat reacting to the presence of another.

---

### Core bootstrapping

#### BootAnalyzeGroupsInCondition.R

This is the main file that chews through the original data, and constructs bootstrap replicates based on actual rat trajectories, but that we’re not from the same actual run (recording). In other words, each “rat” in the bootstrap run could not have adjusted its behavior based on the other “rats” in the bootstrapped trial. The rats were, in effect, ghost rats that could not see, smell, or feel one another.

In this version, all rat trajectories come from the same condition. In other words, for a “3 rats” bootstrap run, all rat trajectories came from rats that ran with only 2 other rats.

#### BootMotherAnalyzeGroupsInCond.R

Same as above, except that a rat in a “3 rat” bootstrap replicate could have come from a 15 rat condition, i.e. might have been actually in the box with 14 other rats.

### Summarizing and plotting the results

PlotRealAndBootSummary.R

PlotBootVsBootDistributions.R

make_boot_hist.R

