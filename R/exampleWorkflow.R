# example workflow

library(here)
library(sp)
library(sf)
library(rgeos)
library(tictoc)
library(RColorBrewer)
library(tidyverse)
# tic("running")
# toc()
# library(raster)



# where are the functions
source(here("scripts/connectFunctions.R"))
# set the outfolder
outfolder <- here("data/derivedData/")

# set distance buffer to half the animals' dispersal distance in metres
distances <- seq(5, 800, by = 10)
# distances <- c(50)

# 1. load habitat layer
# hab <- load_hab(here("data/GISdata/PhaseOne_files/Frog/", ""))

# 2. load barrier layer
bar1 <- load_bar(here("data/GISdata/PhaseOne_files/Parrot/", "AllWoodbirdBarriers_CorrCRS.shp"))
# clean the barrier layer
bar <- clean(bar1)

# save clean barrier layer
st_write(bar, paste0(outfolder,"/Parrot_cleanBarrier.shp"))
# bar <- load_bar(here("data/derivedData/Frog_cleanBarrier.shp"))

# dataframe to store the connectivity outputs for different distance thresholds
results <- data.frame(distance = rep(NA, length(distances)),
                      effMesh = NA,
                      meanArea = NA,
                      numberConnect = NA)


# set up progress bar
pb <- txtProgressBar(min = 0, max = length(distances), style = 3)
# for loop runs the connectivity function for each distance in 
# the vector of distances
for (i in 1:length(distances)) {
  
  dist <- distances[[i]]
  connectAreas <- connectivity(habitat = hab, barrier = bar, distance = dist)
  
  # save the connected areas dataframe to csv
  write.csv(connectAreas, paste0(dist, "_BatConnectedAreas.csv"))
  
  # find effective mesh size (connectivity), mean size of connected area 
  # and number of connected areas
  connectValue <- calc_connectivity(connectAreas)
  mean_size <- calc_mean_size(connectAreas)
  numAreas <- calc_num_areas(connectAreas)
  
  # output results
  results$distance[i] <- dist
  results$effMesh[i] <- connectValue
  results$meanArea[i] <- mean_size
  results$numberConnect[i] <- numAreas
  
  # update progress bar
  setTxtProgressBar(pb, i)
  
}
close(pb)


# output to csv
write.csv(results, "/BatConnectivityValues.csv")


