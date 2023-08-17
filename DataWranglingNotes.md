# Data analysis Notes
This is just "as we go" notes and thoughts on the data analysis in roughly chronological order.

## Dealing with NaNs.
## Can ignore this – problem solved

There are a lot of NaNs, and they seem to be interspersed in the data; like not just at the beginning and end. This presents a challange.

I think that, for each experiment, we drop frames in which any frame has a NaN for a rat.

This will result in "time jumps" in the data.

Current thoughts:
- for each data file of a session, we mark all rows where any rat has a NaN
- we then generate a new file with NaN rows dropped, with a column indicating time drops and number of frames dropped
- we analyze the time dropped data for spatial proximity
- for calculating the movement statistics, we need to separate out the data by time drops
    - In other words, to calculates the movement stats, we can't include the sudden changes due to time drops. 

## OMG, I'm so dumb.
### solution to above

I just realized that we can simply drop the NaNs (any frames where either x and y are NaN) and use the first difference of the frames column to identify the time drops and how much time was dropped. Like, we don't need a `for()` loop or complex logical indexing.

## Definitions

Each time rats are released into the box, I'm calling that a "run" – a single video recording

A set of identical runs (e.g. n=3 rats), I'm calling that that a "block"

A set of blocks with different rat numbers in each block is an "expermient". So, the data we're working on now is one experiment, the "baseline experiment".

## Physical layout Info
### Camera conversion
pixel/inch: 17.9394
pixel/cm: 7.0627

### Cage Dimensions
45" x 41" in 

### rotation might be nice
7-Aug-23 lkc – The camera is not square with respect to the cage, so if we want to have x,y data that aligns with the cage sides, we'll need to rotate the data. So I guess that would look like: offset by camera center coordinates, apply rotation matrix, reverse offset.

## Workflow
### "By hand" single run analysis workflow  
7-Aug-23 lkc The "by hand" workflow is in place. At each step, the user is prompted to open a file, that step of the analysis is done, and then the user is prompted to save a file.

CombineRatDataInARun.R – combine rat files from a single run into a single xyt_dat data frame  
DBScanClustering.R – do the clustering and add cluster and seed labels to xyt_dat  
ComputeGroupStats.R – compute group sizes, lengths in time, etc.

### Data wrangling insight!
7-Aug-23 lkc  Combining the data for each run need only be done once, and should not clutter up the actual analysis workflow.
So today's goal is to write a script that can go through a session and do the combination run by run.  
(or, if I'm ambitions, for all sessions in an experiment in one go.

Note: for the bootstrapping, we can't pre-combine the data from a run, but it might speed things up to still have .RData files for each rat to avoid having to load .csv files in the bootstrapping loop.

**17-Aug-23 update** - MakeDataFilesFromCSVs.R now converts the raw files to formatted data frames in .RData files, rat by rat (file by file).

### One possible puzzle to solve
Let's say there are two groups running simultaneously, groups "1" and "2", and then group 1 disperses. The former group 2 would then become group 1, so we have to check for that and adjust the labels for continuity.

This would bias the averages towards shorter groups, but it will do the exact same thing for the bootstrapping.

### Automated whole-session workflow
17-Aug-23 lkc  Pieces in place, but...

### Bug Alert!!!
I'm getting a wierd bug when transforming the data into wide array form for the rle encoding step. It's weird enough that I'm going back to the beginning to make sure everything is working exactly as exprected step by step.
Starting with
#### CombineRatDataInARun.R
Comine…R:
Orig stacked = 139968 rows
Each = 46656 
3 x 46656 = 139968 - check!

After nan removal
xyt_dat = 86485 rows

> `any(is.na(xyt_dat))`
[1] FALSE

Loading saved file gives
xyt_dat = 86485 rows - check!

*I’m considering Combine…R to be fully vetted unless no other possibility exists.*



















