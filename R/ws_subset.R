#' Subset ORNL DAAC HWSD data
#'
#' Subset function to query pixel or spatial data from the
#' ORNL DAAC HWSD THREDDS server. Returns a tidy data frame
#' for point locations or raster data to the workspace or
#' disk.
#' 
#' @param site sitename for the extracted location
#' @param location location of a bounding box c(lon, lat, lon, lat) defined
#' by a bottom-left and top-right coordinates, a single location (lon, lat)
#' @param param soil parameters to provide, the default setting is ALL, this 
#' will download all available soil parameters.Check
#' https://daac.ornl.gov/SOILS/guides/HWSD.html for parameter descriptions.
#' @param layer which soil depth layer of HWSD v2.0 to consider, layers are
#'  named D1 to D7 from top to bottom
#' @param path path where to download the data to (only applicable to
#' spatial data)
#' @param ws_path path to the gridded HWSD v2.0 data, only required/used if
#'  querying v2.0 data
#' @param version version of HWSD to query (numeric value). By default the
#'  package will query the ORNL DAAC v1.2 via their API. If specifying the
#'  later version (2.0) it will download or require the gridded spatial data
#'  in addition to the included HWSD v2.0 database with soil parameters.
#' @param internal do not store the data on disk
#' @param rate request rate in seconds, determines how long to wait between 
#'  queries to avoid bouncing because of rate limitations
#' @param verbose verbose output during processing, only covers the internal
#'  use of the ws_download() function for HWSD v2.0 data
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
#'  terra::plot(t_sand)
#' }

ws_subset <- function(
  location = c(32, -81, 34, -80),
  site = "HWSD",
  param = "ALL",
  layer = "D1",
  path = tempdir(),
  ws_path = file.path(tempdir(), "ws_db"),
  internal = TRUE,
  rate = 0.1,
  version = 1.2,
  verbose = FALSE
){
  
  # check coordinate length
  if (!(length(location) == 2 || length(location) == 4)){
    stop("Location parameters of insufficient length, check coordinates!")
  }
  
  if (as.numeric(version) < 2) {
    
    # grab meta-data from package
    meta_data <- hwsdr::hwsd_meta_data
    
    if(tolower(param) != "all" & any(!(param %in% meta_data$parameter))){
      stop("One or more soil parameters are not valid!")
    }
    
    # check if there are enough coordinates specified
    if (length(location) != 4){
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
    ws_stack <- terra::rast(ws_stack)
    
    # if only a single location is provided
    # extract the pixel values and return
    # as a data frame
    if(!bbox){
      
      # define sf point location
      p <- sf::st_as_sf(data.frame(
        lat = location[2],
        lon = location[1]),
        coords = c("lon","lat"),
        crs = 4326)
      
      # extract values
      values <- terra::extract(ws_stack, p)
      
      # convert to tidy data
      values <- data.frame(
        site = site,
        parameter = names(values),
        latitude = location[2],
        longitude = location[1], 
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
        terra::writeRaster(
          ws_stack,
          filename = file.path(path,
                               sprintf("%s.tif",
                                       site)),
          overwrite = TRUE)   
      )
    }
  
  } else {
    
    # CRAN fix
    LAYER <- HWSD2_SMU_ID <- NULL
    
    # grab the full database
    hwsd2 <- hwsdr::hwsd2 |>
      dplyr::filter(
        LAYER == layer
      )

    # split out the meta-data (column names)
    meta_data <- hwsd2 |>
      names()
    
    if(all(tolower(param) != "all") & any(!(param %in% meta_data))){
      stop("One or more soil parameters are not valid!")
    }
    
    # download the gridded data if not available in
    # the tempdir() or elsewhere
    if (ws_path == file.path(tempdir(), "ws_db")) {
      if(!dir.exists(file.path(tempdir(), "ws_db"))) {
        ws_path <- ws_download(
          ws_path = file.path(tempdir(), "ws_db"),
          verbose = verbose
        )
      } else {
        if(!file.exists(file.path(ws_path, "HWSD2.bil"))) {
          ws_path <- ws_download(
            ws_path = ws_path,
            verbose = verbose
          )
        }
      }
    }
    
    ws_stack <- 
      lapply(param, function(par){
        
        # read in raster grid, i.e IDs linking locations to
        # database values
        ids <- terra::rast(file.path(ws_path, "HWSD2.bil"))
        
        if (length(location) > 2) {
          
          # set filename
          filename <- file.path(
            path,
            paste0(par, ".nc")
          )
          
          # set the extent of the subset
          e <- terra::ext(location)
          
          # crop the full image to extent
          c <- terra::crop(ids, e)
          
          # map values to the gridded indices
          output <- try(
            terra::subst(
              c,
              from = hwsd2$HWSD2_SMU_ID,
              to = hwsd2[par]
            )
          )
          
          if(inherits(output, "try-error")){
            stop(
            "Value subsitution requires numeric values,\n check selected values!"
            )
          }
          
          return(output)
        } else {
          # define sf point location
          p <- sf::st_as_sf(data.frame(
            lon = location[1],
            lat = location[2]),
            coords = c("lon","lat"),
            crs = 4326
            )
          
          # extract values
          pixel_id <- terra::extract(
            ids,
            p
          )
          
          # select and filter output
          output <- hwsd2 |>
            dplyr::filter(
              HWSD2_SMU_ID == pixel_id$HWSD2
            ) |>
            dplyr::select( 
              dplyr::all_of(par)
            ) |>
            dplyr::mutate(
              latitude = location[2],
              longitude = location[1],
              site = site,
              parameter = par
            ) |>
            dplyr::rename(
              "value" = !!par
            )
          
          return(output)
        }
      })
    
    if(all(is.null(ws_stack))){
      warning("No data retrieved!")
      return(NULL)
    }
    
    if (length(location) == 2) {
      ws_stack <- dplyr::bind_rows(ws_stack)
      return(ws_stack)
    }
    
    if (length(location) == 4) {
      ws_stack <- terra::rast(c(ws_stack))
    }
    
    # if internal return the raster stack
    # otherwise write to file as a geotiff
    # in the desired path
    if(internal & length(location) == 4){
      return(ws_stack)
    } else {
      terra::writeRaster(
        ws_stack,
        file.path(path, paste0(c(site, layer, ".tif"), collapse = "_")),
        overwrite = TRUE
      )
    }
  }
}
