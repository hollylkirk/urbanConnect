# script to run the different parking reallocation scenarios for MCR
library(here)
library(sf)
library(tidyverse)
library(raster)

# where are the functions
source(here("scripts/connectFunctions.R"))
# set the outfolder
outfolder <- here("data/connectOutputs/")


# load files for existing MCR habitat, buffered habitat and barriers
# habitat layer
hab <- load_hab(here("data/rawData/MCR/grassAndUnder.shp"))
# buffered habitat layer
buffHab <- load_hab(here("data/rawData/MCR/MCRhabBuff.shp"))
buffHab <- st_union(buffHab, by_feature = FALSE)
# barrier layer
bar <- load_bar(here("data/rawData/roads/RoadRail5mNoGapsDiss.shp"))
bar <- clean(bar)
# slight buffer to remove complexity around the road layer
bar <- st_buffer(bar, dist = 0.5, nQuadSegs = 5)


# Prepare the parking space reallocation data layer
parklets <- st_read(here("data/rawData/parklets/parkletPolygons.shp"))
# filter to the right scenario, e.g. Viable14 == 1
# scenario <- filter(parklets, Viable12 == 1)
# scenario <- filter(parklets, Viable13 == 1)
scenario <- filter(parklets, Viable14 == 1)

# extract just the geometry
scenario <- sf::st_geometry(scenario)
scenario <- clean(scenario)


# prep the habitat layer (combine scenario buffer and existing habitat buffer)
# buffer scenario
scenarioBuff <- st_buffer(scenario, dist = 150, nQuadSegs = 5)
scenarioBuff <- st_union(scenarioBuff, by_feature = FALSE)
# add to buffered habitat
newHabBuff <- st_union(buffHab, scenarioBuff)

# add new habitat patches from parking reallocation to the existing habitat
newHab <- st_union(hab, scenario)
newHab <- clean(newHab)

# make sure that the fragmentation geometry is also affected by the addtion of the 
# new habitat (reducing the barrier effect of some roads)
# create holes in the road barrier layer for the parklets
holes <- st_difference(bar, scenario)
# do the negative buffer to make sure the parklets actually punch holes through the road barriers
buffHoles1 <- st_buffer(holes, dist = -5, nQuadSegs = 5, joinStyle = "MITRE", endCapStyle = "SQUARE", mitreLimit = 5) # negative buffer to punch
buffHoles2 <- st_buffer(buffHoles1, dist = 5, nQuadSegs = 5, joinStyle = "MITRE",  endCapStyle = "SQUARE", mitreLimit = 5) # rebuffering to square
holeyBars <- st_buffer(buffHoles2, dist = 0.5, nQuadSegs = 5) # tidy edges to make them meet again
# st_write(holeyBars, "data/preppedLayers/HolesScenario14.shp")


# run connectivity calculation
# create new fragmentation geometry
fragHab <- fragment_Geometry(newHabBuff, holeyBars)
# remove all habitat under the updated barriers
remainHab <- remaining_patches(newHab, holeyBars)
# identify the remaining habitat patches according to which connected area they belong to
IDremainHab <- identify_patches(remainHab, fragHab)
# calculate area of each habitat patch
areaH <- patch_area(IDremainHab)
# group the patches by connected area ID
connectHabs <- group_connect_areas(areaH)
# save the ID'd patches to a shapefile
st_write(IDremainHab, "data/connectOutputs/MCR_Scenario14.shp")
# save the areas as a spreadsheet for later calculation 
write.csv(connectHabs, "data/connectOutputs/MCR_scenario14.csv")




