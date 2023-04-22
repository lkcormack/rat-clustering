#There seems to be a big(ish) problem with NaNs.

I think that, for each experiment, we drop frames in which any frame has a NaN for a rat.

These will result in "time jumps" in the data".

Current thoughts:
- for each data file of a session, we mark all rows where any rat has a NaN
- we then generate a new file with NaN rows dropped, with a column indicating time drops and number of frames dropped
- we analyse the time dropped data for spatial proximity
- for calculating the movement statistics, we need to seperate out the data by time drops
-In other words, to calculates the movement stats, we can't include the sudden changes due to time drops. 

## OMG

I just realized that we can simple drop the NaNs and use the first difference of the frames column to identify the time drops and how much time was dropped

### I'm so dumb.
