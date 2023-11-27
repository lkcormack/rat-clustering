# goes with LoadAllSumData.R
# you have to run that first to get the data

ks3vs6lens <- ks.test(n3rats_lens, n6rats_lens)
ks3vs9lens <- ks.test(n3rats_lens, n9rats_lens)
ks3vs15lens <- ks.test(n3rats_lens, n15rats_lens)
ks6vs9lens <- ks.test(n6rats_lens, n9rats_lens)
ks6vs15lens <- ks.test(n6rats_lens, n15rats_lens)
ks9vs15lens <- ks.test(n9rats_lens, n15rats_lens)

save(ks3vs6lens, ks3vs9lens, ks3vs15lens, 
     ks6vs9lens, ks6vs15lens, ks9vs15lens, 
     file = "KStestsForLens.RData")

ks3vs6vals <- ks.test(n3rats_vals, n6rats_vals)
ks3vs9vals <- ks.test(n3rats_vals, n9rats_vals)
ks3vs15vals <- ks.test(n3rats_vals, n15rats_vals)
ks6vs9vals <- ks.test(n6rats_vals, n9rats_vals)
ks6vs15vals <- ks.test(n6rats_vals, n15rats_vals)
ks9vs15vals <- ks.test(n9rats_vals, n15rats_vals)

save(ks3vs6vals, ks3vs9vals, ks3vs15vals, 
     ks6vs9vals, ks6vs15vals, ks9vs15vals, 
     file = "KStestsForSizes.RData")

