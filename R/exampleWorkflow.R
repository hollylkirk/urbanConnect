# example workflow

library(here) #
library(sf)
library(tidyverse)

# where are the functions? 
source(here("R/connectFunctions.R"))


# 1. load habitat layer
hab <- load_hab(here("data/GISdata/PhaseOne_files/Frog/", ""))

# 2. load barrier layer
bar1 <- load_bar(here("data/GISdata/PhaseOne_files/Parrot/", "AllWoodbirdBarriers_CorrCRS.shp"))
# clean the barrier layer
bar <- clean(bar1)

# set threshold distance
dist <- 10

# run connectivity function
connectAreas <- connectivity(habitat = hab, barrier = bar, distance = dist)
  
# save the connected areas dataframe to csv
write.csv(connectAreas, paste0(dist, "connectedAreas.csv"))

#save the connected areas dataframe to a shape file for plotting
st_write(connectAreas, paste0(dist, "connectedAreas.shp"))
  
# find effective mesh size (connectivity), mean size of connected area 
# and number of connected areas
effectiveMeshsize <- calc_connectivity(connectAreas)
mean_size <- calc_mean_size(connectAreas)
numAreas <- calc_num_areas(connectAreas)



