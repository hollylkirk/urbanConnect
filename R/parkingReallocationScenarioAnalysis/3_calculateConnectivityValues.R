# script to calculate connectivity for each of the output files from the 
# the scenario analysis 
library(here)
library(sf)
library(RColorBrewer)
library(tidyverse)

# where are the functions
source(here("scripts/connectFunctions.R"))
# set the outfolder
outfolder <- here("data/connectOutputs/")

#make an empty data frame to store data in 
connectivity <- NULL
meanSize <- NULL
numConnectArea <- NULL
total_A <- NULL

# read files with names of the form '.csv'
dat_files = list.files(pattern = '.csv');
# read txt files into a list (assuming separator is a comma)
data_list = lapply(dat_files, read.csv, header= TRUE, sep = ",")

# Mole Cricket existing connectivity:
# # effMesh
# 36.45071 Ha
# # mean_size
# 1.676445
# # numAreas
# 233
# # totalArea
# 390.6118 = 3906118 m2


for (i in 1:length(data_list)) {
  
  df <- data_list[[i]] # load data from file
  # calculate connectivity index
  effMesh <- sum(df$areaSquared) / 3906118 # use the existing total habitat area to measure change
  effMesh <- effMesh * 0.0001
  # mean connected area size
  mean_size <- mean(df$total_area)
  mean_size <- mean_size * 0.0001
  # number of connected areas
  numAreas <- length(df$total_area)
  # total habitat area 
  totalArea <- sum(df$total_area)
  totalArea <- totalArea * 0.0001
  
  connectivity <- c(connectivity, effMesh)
  meanSize <- c(meanSize, mean_size)
  numConnectArea <- c(numConnectArea, numAreas)
  total_A <- c(total_A, totalArea)
  
  
}

# combine the different outputs
results <- cbind(dat_files, connectivity)
results <- cbind(results, meanSize)
results <- cbind(results, numConnectArea)
results <- cbind(results, total_A)

# head(results)
# output to csv
write.csv(results, paste(outfolder, "MCRresults.csv", sep= '/'))

