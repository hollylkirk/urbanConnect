# functions used in the workflow for calculating 
# effective mesh size (Connectivity Index)

# function to load the habitat shape file
# This function uses the SF package to extract just the spatial information from a shape file
load_hab <- function(habitatFile, ...) {
  habitat <- sf::st_read(habitatFile) # read in shape file from file name or file path
  habitat <- sf::st_geometry(habitat) # extract just the spatial portion of the file. 
  habitat
}

# function to load the barrier shape file
# This function uses the SF package to extract just the spatial information from a shape file
load_bar <- function(barrierFile, ...) {
  barrier <- sf::st_read(barrierFile) # read in shape file from file name or file path
  barrier <- sf::st_geometry(barrier) # extract just the spatial portion of the file
  barrier
}


# clean any spatial data layer (shape file)
# many shape files contain errors, places where the edges of a polygon cross over or polygons which overlap
# this function helps to remove some of those errors by smoothing the edges of polygons, removing corners
# and dissolving edges where polygons overlap. This reduces the complexity of the shape file, making future steps quicker
clean <- function(spatialData, ...) {
  cd <- sf::st_buffer(spatialData, dist = 0, nQuadSegs = 5) # buffer by a small amount
  cd <- sf::st_union(cd, by_feature = FALSE) # union to create one large polygon rather than multiple small ones
  cd <- sf::st_simplify(cd, dTolerance = 1) # simplify to remove some vertices
  cd
}


# buffer the habitat by half the threshold distance (the distance past which habitat
# patches are no longer considered connected)
# This 
habitat_buff <- function(habitat, distance) {
  hb <- sf::st_buffer(habitat, dist = distance, nQuadSegs = 5) # buffer by the required distance
  hb <- sf::st_union(hb, by_feature = FALSE) # union creates one large polygon rather than multiple small ones
  hb
}


# create the fragmentation geometry
fragment_Geometry <- function(bufferedHabitat, barrier) {
  fg <- sf::st_difference(bufferedHabitat, barrier) # difference removes the road polygon areas from the buffered habitat polygon, creating gaps
  fg <- sf::st_cast(fg, "POLYGON") # creates individual polygons, rather than one mega polygon
  fg <- sf::st_sf(fg) 
  fg$ID <- seq.int(nrow(fg)) # squentially number the 
  fg
}


# original habitat patches underneath barriers need to be removed
remaining_patches <- function(habitat, barrier) {
  # remove all habitat under barriers
  hab_barrier_remove <- sf::st_difference(habitat, barrier)
  # split multipolygon into the original number of separate polygons  
  hab_barrier_remove <- sf::st_cast(hab_barrier_remove, "POLYGON")
  hab_barrier_remove
}


# clean membership function to account for when some fragments appear in no buffered areas,
# or some appear in more than one.
clean_inter <- function(membership_vector) {
  # check for empty vectors
  if (length(membership_vector) == 0) {
    membership_vector <- NA
  }
  
  if (length(membership_vector) > 1){
    membership_vector <- membership_vector[1]
    warning("One of the fragments occurs in more than one buffered area, ",
            "so has been assigned to the first area in the list")
  }
  membership_vector
}



# identify which of the remaining original habitat patches belong in which connected area
identify_patches <- function(remaining, fragID) {
  inter <- sf::st_intersects(remaining, fragID)
  # code to sanitise "inter"  (a list of vectors) to make sure any empty vectors are non-empty
  # and make sure there are no vectors longer that 1
  cleaned_inter <- lapply(inter, clean_inter)
  membership <- unlist(cleaned_inter)
  habID <- sf::st_sf(geometry = remaining, cluster = membership)
  habID
}


# calculate area of each habitat patch
patch_area <- function(patches) {
  patches$area <- sf::st_area(patches)
  areas <- data.frame(cbind(patches$cluster, patches$area))
  # rename columns              
  names(areas)[1] <- "patchID"
  names(areas)[2] <- "area"
  areas
}


# function to group the remaining habitat patches by area
group_connect_areas <- function(patchAreas) {
  grouped <- group_by(patchAreas, patchID)
  summed <- summarise(grouped, total_area = sum(area))
  # create a column with  area squared in it
  summed$areaSquared <- summed$total_area^2
  summed
}

# the connectivity calculation
calc_connectivity <- function(groupedAreas) {
  effMesh <- sum(groupedAreas$areaSquared) / sum(groupedAreas$total_area)
  # convert to hectares
  effMesh <- effMesh * 0.0001
  # return
  effMesh
  
}

# calculate mean size of connected areas
calc_mean_size <- function(groupedAreas) {
  mean_size <- mean(groupedAreas$total_area)
  # return
  mean_size
  
}

# find number of connected areas
calc_num_areas <- function(groupedAreas) {
  numAreas <- length(groupedAreas$total_area)
  # return
  numAreas
  
}


# function to run the calculate connectivity functions
# x = habitat layer
# y = barrier layer
# d = distance used as a threshold for whether habitat patches are joined or not.
connectivity <- function(habitat, barrier, distance) {
  # buffer the habitat layer by the distance
  buff <- habitat_buff(habitat, distance)
  # create fragmentation geometry
  frag <- fragment_Geometry(buff, barrier)
  # clean the original habitat layer up
  simpleHab <- clean(habitat)
  # remove all habitat under barriers
  remainingHab <- remaining_patches(simpleHab, barrier)
  # identify the remaining habitat patches according to which connected area they belong to
  IDRemainingHab <- identify_patches(remainingHab, frag)
  # calculate area of each habitat patch
  areaHab <- patch_area(IDRemainingHab)
  # group the patches by connected area ID
  connectAreas <- group_connect_areas(areaHab)
  connectAreas
}
