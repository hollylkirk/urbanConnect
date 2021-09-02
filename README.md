# urbanConnect
Reproducible workflow in R for measuring **ecological connectivity** in urban areas. 

Here you will find a collection of R scripts, functions and tutorials for calculating an ecological connectivity index based on "effective mesh size", a geometric measure of connectivity developed by [Jochen Jaeger (2000)](https://doi.org/10.1023/A:1008129329289), see also [Spanowicz & Jaeger 2019](https://doi.org/10.1007/s10980-019-00881-0). This method has also been used by [(Deslauriers et al. 2017)](https://www.sciencedirect.com/science/article/pii/S1470160X17300912) in the development of the City Biodiversity Index #2.

Here we present a set of R functions that can be used to compute effective mesh size in urban areas. These functions all require installation of the `sf` package (more information about `sf` [here](https://r-spatial.github.io/sf/)). The functions were developed using `sf` version 0.9.3. 

The workflow requires three main data inputs:
* A spatial polygon file that represents available _habitat_
* A spatial polygon file that repesents any _barriers to movement_
* A _threshold distance_ (in metres) that represents how close habitat patches need to be to each other to be considered "connected"

For an example of how this method has been applied in a real-life urban planning scenario in the City of Melbourne you can download [this report](https://nespurban.edu.au/wp-content/uploads/2021/02/Linking-nature-in-the-city-Part-2.pdf).

## How to get started
All the main functions for calculating effective mesh size can be found in the `connectFunctions` file in the R folder

A demonstration workflow with a tutorial coming soon!

![GIS layers around Fitzroy Gardens, Melbourne, Australia](images/ZoomedInFitzroyGardens.png)
