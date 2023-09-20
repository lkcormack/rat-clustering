filename <- "/Users/lkc3-admin/Documents/GitHub/rat-clustering/data/3Rats/Average_Position_02/Rat2Run2n_Rats3.RData"
# Extract the "RatxRunx" pattern
id_string <- sub(".*/(Rat\\d+Run\\d+).*", "\\1", filename)

print(id_string)
