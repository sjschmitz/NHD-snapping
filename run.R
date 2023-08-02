# AS NEEDED, MODIFY CODE IN "_targets.R" OR IN FILES IN "R" FOLDER; DO NOT MODIFY CODE HERE

# RUN FOLLOWING LINES IN SEQUENCE, ONE BY ONE

library(targets)

tar_outdated()

tar_make_clustermq(workers = 6)

tar_visnetwork(targets_only = TRUE)
