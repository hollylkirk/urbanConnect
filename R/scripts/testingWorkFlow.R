rm(list = ls())
# general script to load the raw database exported data for an area site, 
# filter and reshape accordingly, export as csvs for use in later scripts

library(here)
library(sp)
library(sf)
library(rgeos)
library(raster)
# library(tidyverse)

# where are the functions
source(here("scripts/connectFunctions.R"))

# set the outfolder
outfolder <- here("data/derivedData/")



# load habitat layer
hab <- st_read(here("data/GISdata/PhaseOne_files/AllVegetation/", "AllVeg.shp"))

# load barrier layer
bar <- st_read(here("data/GISdata/PhaseOne_files/AllVegetation/", "AllBarriers10m_75mBuffDiss.shp"))

