### Backing out the standard error of the mean group size and length from the bootstrap simulations.

The bootstrap simulations currently count the total number of groups within every given histogram bin for both group size and length (or duration) across the 15 runs of a simulated experiment. What holds for one bin holds for all bins for both the size and duration histograms.

If, instead, we want to estimate the mean count for a given bin in a single run and its standard error (the standard deviation of mean count across the 15 runs), it can be done as follows.

For each histogram bin, the bootstrapping yields good estimates of 

#### the estimate of the total count across runs for an experiment

$$
\hat{t}_e
$$

#### the standard deviation of this estimate

$$
s_{\hat{t_e}}
$$

---

The bootstrapped total in (1) is just an estimate the sum of the run totals for each experiment
$$
t_e=t_{r1}+t_{r2}+t_{r3}+...+t_{r15}=\sum_{i=1}^{15}t_{i}
$$
So the estimate the count for a *run* is just the total over 15
$$
\hat{t_r}=\frac{\hat{t_e}}{15}
$$

---

The *variance* of the estimated total in (1) is the sum of the variances contributing the total
$$
{s^2}_{t_e}={s^2}_{r1}+{s^2}_{r2}+{s^2}_{r3}+...+{s^2}_{r15}=\sum_{i=1}^{15}{s^2}_{i}
$$
So the estimate of the run *varience* is 
$$
\hat{s}{^2}_{r}=\frac{{s^2}_{t_e}}{15}
$$
And so the corresponding standard deviation (the standard error of mean across runs for one experiment) is 
$$
\hat{s}_{r}=\sqrt{\frac{{s^2}_{t_e}}{15}}=\frac{s_{\hat{t_e}}}{\sqrt{15}}
$$
In other words, the standard deviation given by the bootstrapping over the square root of the number of runs.

