#' Basic HWSD download function
#' 
#' Downloads HWSD data, wrapped by \code{ws_subset()} for convenient use. This is a
#' function mainly for internal use but exposed so people can benefit from
#' it in other (more flexible) setups if so desired.
#' 
#' @param location file with several site locations and coordinates
#' in a comma delimited format: site, latitude, longitude
#' @param param which soil parameter to use
#' @param path default is tempdir()
#' @param internal return an internal raster or just retain values in the path
#' @return HWSD data as a raster file
#' @export

ws_get <- function(
  location,
  param,
  path,
  internal = TRUE
){

  # grab meta-data from package
  meta_data <- hwsdr::hwsd_meta_data
  
  # check parameter
  if(meta_data$subset[meta_data$parameter == param] != ""){
    var <- meta_data$subset[meta_data$parameter == param]
  } else {
    var <- param
  }
  
  # formulate query to pass to httr
  query <- list(
    "var" = var,
    "south" = location[2],
    "west" = location[1],
    "east" = location[3],
    "north" = location[4],
    "disableProjSubset" = "on",
    "horizStride"= 1,
    "accept"="netcdf4"
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
  
  # on error check if var settings need
  # to be converted to lower
  if(httr::http_error(status)){
    
    query$var <- tolower(query$var)
    
    # download data, force binary data mode
    status <- httr::GET(url = url,
                        query = query,
                        httr::write_disk(
                          path = file,
                          overwrite = TRUE))
  }
  
  # if after that the query is still bad
  # return NULL
  if(httr::http_error(status)){
    
    # report error (don't fail)
    message(sprintf("data not downloaded for: %s",param))
    return(NULL)
    
  } else {
    r <- terra::rast(file)
    return(r)
  }
}