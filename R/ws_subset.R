#' Function to geographically subset 'Daymet' regions exceeding tile limits
#'
#' @param site sitename for the extracted location
#' @param location location of a bounding box c(lat, lon, lat, lon) defined
#' by a top left and bottom-right coordinates, a single location (lat, lon)
#' or a data frame with various locations listed (site, lat, lon)
#' @param param soil parameters to provide, the default setting is ALL, this 
#' will download all available soil parameters.Check
#' https://daac.ornl.gov/SOILS/guides/HWSD.html for parameter descriptions.
#' @param path path where to download the data to (only applicable to
#' spatial data)
#' @param internal do not store the data on disk
#' @param rate request rate in seconds, determines how long to wait between 
#'  queries to avoid bouncing because of rate limitations
#' @return netCDF data, or a data frame with HWSD soil information
#' 
#' @export
#' @examples
#' 
#' \dontrun{
#' print("test")
#' }

ws_subset <- function(
  site = "HWSD",
  location = c(34, -81, 32, -80),
  param = "ALL",
  path = tempdir(),
  internal = TRUE,
  rate = 10
){
  
  # check if there are enough coordinates specified
  if (length(location)!=4){
    bbox <- FALSE
    
    # pad the point locations
    # as the query needs a bounding box
    location <- c(
      location[1] + 0.05,
      location[2] - 0.05,
      location[1] - 0.05,
      location[2] + 0.05
    )
    
  } else {
    bbox <- TRUE
  }
  
  # check the parameters we want to download in case of
  # ALL list all available parameters for each frequency
  if (any(grepl("ALL", toupper(param)))) {
    # Use meta-data file to select all but the CLM
    # parameters when calling ALL
    param <- hwsd_meta_data$parameter[
        hwsd_meta_data$parameter != "HWSD_SOIL_CLM_RES"
        ]
  }
  
  ws_stack <- 
    lapply(param, function(par){
      # Wait to avoid rate limitations
      Sys.sleep(rate)
      
      # get data
      ws_get(
        location = location,
        param = par,
        path = tempdir())
      })
  
  if(all(is.null(ws_stack))){
    warning("No data retrieved!")
    return(invisible())
  }
  
  # convert the nested list to a nice
  # raster stack
  ws_stack <- raster::stack(ws_stack)
  
  # if only a single location is provided
  # extract the pixel values and return
  # as a data frame
  if(!bbox){
    
    # define sf point location
    p <- sf::st_as_sf(data.frame(
      lat = location[1],
      lon = location[2]),
      coords = c("lon","lat"),
      crs = 4326)
    
    # extract values
    values <- raster::extract(ws_stack, p)
    
    return(data.frame(values))
  }

  # if internal return the raster stack
  # otherwise write to file as a geotiff
  # in the desired path
  if(internal){
    return(ws_stack)
  } else {
    suppressWarnings(
      raster::writeRaster(
        ws_stack,
        filename = file.path(path,
                             sprintf("%s.tif",
                                     site)),
        format = "GTiff",
        overwrite = TRUE)   
    )
  }
}
