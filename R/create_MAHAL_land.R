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

#######--- convert Mahal FETA to suitable habitat based on D2, underlying FHEzone and threshold value (based on Rich's analysis = Mean, Max, SD or combination)
create_MAHAL_land <- function(rFHzone,
                              rMahal,
                              mahal_metric,
                              D2_param){
  
  # Raster with mahalanobis distance (D2) values
  # Use mahal_metric to determine which value is our cap for suitable habitat

  mahal_tmp <- mahal_metric %>% dplyr::select("FHE_zone_num", all_of(D2_param))
  if (ncol(mahal_tmp) >2 ) {
  mahal_tmp$CapD2 <- rowSums(mahal_tmp[,2:ncol(mahal_tmp)])
  } else {mahal_tmp$CapD2 <- mahal_tmp[,2]}

  FHzones <- unique(rFHzone@data@values)
  FHzones <- FHzones[!is.na(FHzones)]

  # freq(rMahal)
  
  rMahal_list <- list()
  for(i in 1:length(FHzones)){
    rFHzone_tmp <- rFHzone==FHzones[[i]]
    rFHzone_tmp[rFHzone_tmp<1] <- NA
    rMahal_list[[i]] <- raster::mask(rMahal <= as.numeric(mahal_tmp[1,c("CapD2")]), rFHzone_tmp)
  }

  # sum(rMahal_list[[1]]@data@values, na.rm=TRUE)+sum(rMahal_list[[2]]@data@values, na.rm=TRUE)+sum(rMahal_list[[3]]@data@values, na.rm=TRUE)

  rMahal_brick <- brick(rMahal_list)
  
  if(length(rMahal_list)==1){
    rMahal_ST <- rMahal_list[[1]]
    rMahal_ST[is.na(rMahal_ST[])] <- 0
  } else {  rMahal_ST <- calc(rMahal_brick, sum, na.rm=TRUE) }

  # plot(rMahal_ST)
  # sum(rMahal_ST@data@values)

  land <- raster2world(rMahal_ST)

  return(land)

}

# getwd()
# flexRasWorld <-  readRDS("./modules/FLEX/data/flexRasWorld.rds")
# 
# land <- create_MAHAL_land(rFHzone = flexRasWorld[[1]], # 1=Boreal, 2=Sub-boreal moist, 3=Sub-boreal dry, 4= Dry forest
#                           rMahal = flexRasWorld[[2]][[1]], # Mahalanobis distances for NetLogo world, subsequent rasters are 5 at year intervals
#                           mahal_metric = fread(file.path(paste0(getwd(),"/modules/FLEX/"),"data/mahal_metric.csv"), select=c(1:5)),
#                           D2_param = c("Max","SD"))
# plot(flexRasWorld[[1]])
