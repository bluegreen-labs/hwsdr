#' Basic HWSD download function
#' 
#' Downloads HWSD data, wrapped by ws_subset() for convenient use
#' 
#' @param location file with several site locations and coordinates
#' in a comma delimited format: site, latitude, longitude
#' @param param which soil parameter to use
#' @param path default is tempdir()
#' @param internal return an internal raster or just retain values in the path
#' @return HWSD data
#' @export

ws_get <- function(
  location,
  param,
  path,
  internal = TRUE
){

  # formulate query to pass to httr
  query <- list(
    "var" = param,
    "north" = location[1],
    "west" = location[2],
    "east" = location[4],
    "south" = location[3],
    "disableProjSubset" = "on",
    "horizStride"= 1,
    "accept"="netcdf"
  )
  
  # create url string (varies per product / param)
  url <- sprintf("%s/%s.nc4",
               server(),
               param)
  
  # create file path
  file <- file.path(path,
                    sprintf(
                      "%s.nc", param)
                    )
  
  # download data, force binary data mode
  status <- httr::GET(url = url,
                      query = query,
                      httr::write_disk(
                        path = file,
                        overwrite = TRUE))
  
  # error / stop on 400 error
  if(httr::http_error(status)){
    
    # report error (don't fail)
    message(sprintf("data not downloaded for: %s",param))
    return(NULL)
    
  } else {
    r <- raster::raster(file)
    #raster::plot(r)
    return(r)
  }
}