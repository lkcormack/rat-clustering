# Dealing with NaNs.
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

If rats are ID'd as part of a triad or not or whatever, I'm calling that an "experiment". So, the data we're working on now is one experiment, the "baseline experiment".

## General Info
### Camera conversion
pixel/inch: 17.9394
pixel/cm: 7.0627

### Cage Dimensions
45" x 41" in 
