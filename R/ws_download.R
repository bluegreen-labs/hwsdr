#' Download HWSD v2.0 data
#'
#' Downloads both the database and gridded HWSD v2.0 data products
#' to a desired output path for subsetting.
#' 
#' When an existing path is used which is not the temporary directory
#' an environmental variable WS_PATH can be set by creating an ~/.Renviron file
#' using usethis::edit_r_environ() and entering the path as:
#' 
#' WS_PATH = "/your/full/path"
#' 
#' This variable will override the default temporary directory if it exists.
#' This allows the gridded data to be stored elsewhere and be forgotten 
#' (while using the {hwsdr} package for HWSD v2.0).
#' 
#' Should you delete the gridded file, the environmental variable should be
#' altered and set again by editting the ~/.Renviron file to a new location.
#'
#' @param ws_path the path / directory where to store the HWSD v2.0 database
#' @param verbose verbose messaging of downloading and managing the gridded
#'  data file
#'
#' @return current data path
#' @export
#'
#' @examples
#' 
#' \dontrun{
#'  
#'  # Download the gridded soil map of
#'  # HWSD v2.0 to the temporary directory
#'  ws_download()
#'  
#'  # download the same data to a specific
#'  # directory (which should exist)
#'  ws_download(
#'   ws_path = "~/my_path"
#'  )
#'  
#'  # download the same data to a specific
#'  # directory (which should exist) and
#'  # update the environmental variable
#'  ws_download(
#'  ws_path = "~/my_path",
#'  verbose = TRUE
#'  )
#' }

ws_download <- function(
    ws_path = file.path(tempdir(), "ws_db"),
    verbose = FALSE
) {
  
  # check if environmental variable is set
  # if so use dir as overriding location
  if(Sys.getenv("WS_PATH") != "") {
    ws_path <- Sys.getenv("WS_PATH")
  }
  
  if (ws_path == file.path(tempdir(), "ws_db")) {
    
    if(verbose) {
      message("Creating temporary HWSD v2.0 directory!")
    }
    
    # create storage path
    if (!dir.exists(ws_path)) {
      dir.create(ws_path, recursive = TRUE)
    }
    
  } else {
    
    if (!dir.exists(ws_path)) {
      
      if(verbose){
        # verbose messaging
        message("HWSD v2.0 grid file location does not exist!")
        if(Sys.getenv("WS_PATH") != ""){
          message("-- path was read from .Renviron overriding function value")
          message("-- Change the .Renviron to alter the grid file location")
        }  
      }
      
      # formal stop
      stop("Non existing directory for grid file")
    } else {

      if (file.exists(file.path(ws_path, "HWSD2.bil"))) {
        
        if (verbose) {
          if(Sys.getenv("WS_PATH") != ""){
            message("Path was read from .Renviron, overriding function value!")
          }
          message("Grid file exists, skipping download.")
          message(
            sprintf("Use the '%s' path in your ws_subset() calls!", ws_path)
            )
        }
        
        # return path
        return(ws_path)
      }
    }
  }
  
  # grab urls
  urls <- server(version = "2.0")
  
  # download zipped gridded data
  httr::GET(
    urls$grid,
    httr::write_disk(
      file.path(ws_path, "hwsd2_raster.zip"),
      overwrite = TRUE
      )
    )
  
  utils::unzip(
    file.path(ws_path, "hwsd2_raster.zip"),
    exdir = ws_path
  )
  
  # clean up zip files
  status <- file.remove(
    c(
      file.path(ws_path, "hwsd2_raster.zip")
    )
  )
  
  if (verbose) {
    message("Downloaded HWSD v2.0 grid file")
    message(sprintf("Use the '%s' path in your ws_subset() calls!", ws_path))
  }
    
  return(ws_path)
}