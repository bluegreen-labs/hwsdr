#' Subset ORNL DAAC HWSD data
#'
#' Subset function to query pixel or spatial data from the
#' ORNL DAAC HWSD THREDDS server. Returns a tidy data frame
#' for point locations or raster data to the workspace or
#' disk.
#' 
#' @param site sitename for the extracted location
#' @param location location of a bounding box c(lat, lon, lat, lon) defined
#' by a bottom-left and top-right coordinates, a single location (lat, lon)
#' or a data frame with various locations listed (site, lat, lon)
#' @param param soil parameters to provide, the default setting is ALL, this 
#' will download all available soil parameters.Check
#' https://daac.ornl.gov/SOILS/guides/HWSD.html for parameter descriptions.
#' @param path path where to download the data to (only applicable to
#' spatial data)
#' @param internal do not store the data on disk
#' @param rate request rate in seconds, determines how long to wait between 
#'  queries to avoid bouncing because of rate limitations
#' @return Local geotiff data, or a data frame with HWSD soil information
#' 
#' @export
#' @examples
#' 
#' \dontrun{
#'  # extract sand fraction values
#'  # for a point location
#'  values <- ws_subset(
#'     site = "HWSD",
#'     location = c(34, -81),
#'     param = "T_SAND"
#'    )
#'    
#'  print(values)
#'  
#'  # Download a soil fraction map
#'  # of sand for a given bounding box
#'  t_sand <- ws_subset(
#'     site = "HWSD",
#'     location = c(32, -81, 34, -80),
#'     param = "T_SAND",
#'     path = tempdir(),
#'     internal = TRUE
#'    )
#'    
#'  raster::plot(t_sand)
#' }

ws_subset <- function(
  location = c(32, -81, 34, -80),
  site = "HWSD",
  param = "ALL",
  path = tempdir(),
  internal = TRUE,
  rate = 0.1
){
  
  # grab meta-data from package
  meta_data <- hwsdr::hwsd_meta_data
  
  if(param != "ALL" && any(!(param %in% meta_data$parameter))){
    stop("One or more soil parameters are not valid!")
  }
  
  # check coordinate length
  if (!(length(location) == 2 || length(location) == 4)){
    stop("Location parameters of insufficient length, check coordinates!")
  }
  
  # check if there are enough coordinates specified
  if (length(location)!=4){
    bbox <- FALSE
    
    # pad the point locations
    # as the query needs a bounding box
    location <- c(
      location[1] - 0.05,
      location[2] - 0.05,
      location[1] + 0.05,
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
    param <- meta_data$parameter[
        meta_data$parameter != "HWSD_SOIL_CLM_RES"
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
      }
    )
  
  if(all(is.null(ws_stack))){
    warning("No data retrieved!")
    return(NULL)
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
    
    # convert to tidy data
    values <- data.frame(
      site = site,
      parameter = param,
      latitude = location[1],
      longitude = location[2], 
      value = t(values),
      row.names = NULL
    )
    
    # return data
    return(values)
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
