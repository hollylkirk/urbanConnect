# script that prepares the different habitat and barrier layers for the mole Cricket analysis
# also runs the existing connectivity calculation (needed for scenario comparisons)

library(here)
library(sf)
library(rgeos)
library(tidyverse)
library(raster)


# where are the functions
source(here("scripts/connectFunctions.R"))
# set the outfolder
outfolder <- here("data/connectOutputs/")

# code to combine different shape files into one habitat layer
# load grass and turf layer
# grass <- load_hab(here("data/rawData/MCR/Grass_LidarAndTurf.shp"))
# grass <- clean(grass)
# # write this to a file so it can be used elsewhere
# # st_write(grass, "data/rawData/Canopy2018/CanopyClean.shp")
# # grass <- load_hab(here("data/rawData/MCR/grassClean.shp"))
# 
# # load understorey1
# under <- load_hab(here("data/rawData/BBB/Under_ShrubAndLidar_CRS.shp"))
# under <- clean(under)

# combine grass and understorey vegetation shape file
# habitat1 <- st_union(under, grass)
# st_write(habitat1, "data/rawData/MCR/grassAndUnder.shp")


# run existing connectivity calculation
# load barriers
bar <- load_bar(here("data/rawData/roads/RoadRail5mNoGapsDiss.shp"))
bar <- clean(bar)
# slight buffer to remove complexity around the road layer
bar <- st_buffer(bar, dist = 0.5, nQuadSegs = 5)

# load habitat
hab <- load_hab(here("data/rawData/MCR/grassAndUnder.shp"))
# further simplify this habitat layer to improve processing time
hab <- st_simplify(hab, dTolerance = 2.5)


# buffer the habitat layer by the distance 150m 
# (half the total dispersal distance threshold)
buffHab <- st_buffer(hab, dist = 150, nQuadSegs = 5)
# save for use in the scenario assessment
st_write(buffHab, "data/rawData/MCR/MCRhabBuff.shp")
# union on the shapes in the buffered file
buffHab <- st_union(buffHab, by_feature = FALSE)

# create fragmentation geometry
fragHab <- fragment_Geometry(buffHab, bar)
# remove all habitat under barriers
remainHab <- remaining_patches(hab, bar)
# identify the remaining habitat patches according to which connected area they belong to
IDremainHab <- identify_patches(remainHab, fragHab)
# calculate area of each habitat patch
areaH <- patch_area(IDremainHab)
# group the patches by connected area ID
connectHabs <- group_connect_areas(areaH)
# save the ID's patches to a shapefile
st_write(IDremainHab, "data/connectOutputs/MCR_existing.shp")
# save area of habitat patches to a spreadsheet for later recalculation
write.csv(connectHabs, "data/connectOutputs/MCR_existing.csv")

# calculation existing connectivity value
connectValue <- calc_connectivity(connectHabs)
mean <- calc_mean_size(connectHabs)
num <- calc_num_areas(connectHabs)

# double checking calculations and making a note of the total habitat area for the 
# scenario analysis
# recheck connectivity calculation, just by inputting the existing habitat patches
df <- read.csv("C:/Users/ilex0/OneDrive/AARR/parklets/data/connectOutputs/MCR_existing.csv")
effMesh <- sum(df$areaSquared) / sum(df$total_area)
effMesh <- effMesh * 0.0001
# mean connected area size
mean_size <- mean(df$total_area)
mean_size <- mean_size * 0.0001
# number of connected areas
numAreas <- length(df$total_area)
# total habitat area 
totalArea <- sum(df$total_area)
totalArea <- totalArea * 0.0001


# # effMesh
# 36.45071 Ha
# # mean_size
# 1.676445 Ha
# # numAreas
# 233 Ha
# # totalArea
# 390.6118 Ha (3906118 m2)



