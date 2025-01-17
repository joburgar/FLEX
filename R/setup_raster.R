# Copyright 2021 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#===========================================================================================#
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#===========================================================================================#

# initial world plot
setup_raster <- function(fishers,
                         land){
  
  # land = Mahal_land[[1]]; fishers=fishers
  rw <- world2raster(land)
  
  # the initial 'world' raster with established adult fisher territories
  r_start <- raster()
  r_start <- setExtent(r_start, rw, keepres=TRUE)
  
  fstart <- fishers
  fs_whoEAF <- fstart[fstart$breed=="adult" & fstart$disperse=="E",]$who
  fs_EAFind <- turtle(fstart, who = fs_whoEAF) # fishers who are dispersing (i.e., kits)
  
  ftmp <- as.data.frame(patchHere(land, fs_EAFind))
  ftmp$Fisher <- 1
  ftmp.sf <- st_as_sf(ftmp, coords = c("pxcor", "pycor"))
  ftmp.sfp <- st_buffer(ftmp.sf, dist=.1)
  
  r_start <- rasterize(ftmp.sfp, r_start, field="Fisher", background=0)
  
  suitable_habitat <- sum(rw@data@values)
  total_habitat <- dim(rw)[1]*dim(rw)[2]
  perc_habitat <- round(suitable_habitat/total_habitat*100,1)
  numAF_start <- length(fs_whoEAF) # number of fisher to start
  
  pop_info <- list(suitable_habitat=suitable_habitat, total_habitat=total_habitat, perc_habitat=perc_habitat, numAF_start=numAF_start)
  
  return(list(r_start=r_start, pop_info=pop_info))

}
