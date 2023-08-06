#' Download HWSD v2.0 data
#'
#' Downloads both the database and gridded HWSD v2.0 data products
#' to a desired output path for subsetting.
#' 
#' When an existing path is used which is not the temporary directory
#' an environmental variable WS_PATH will be set. This variable will
#' override the default temporary directory if it exists. This allows
#' the gridded data to be stored elsewhere and be forgotten (while using the
#' {hwsdr} package for HWSD v2.0).
#' 
#' Should you delete the gridded file, than it can be downloaded again but
#' the environmental variable should be set again using the new_path = TRUE
#' flag.
#'
#' @param ws_path the path / directory where to store the HWSD v2.0 database
#' @param new_path update the path, i.e. dowload data to a new local
#'  location (logical, default FALSE)
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
#'  ws_path = "~/my_path"
#'  )
#'  
#'  # download the same data to a specific
#'  # directory (which should exist) and
#'  # update the environmental variable
#'  ws_download(
#'  ws_path = "~/my_path",
#'  new_path = TRUE
#'  )
#' }

ws_download <- function(
    ws_path = file.path(tempdir(), "ws_db"),
    new_path = FALSE
) {
  
  # check if environmental variable is set
  # if so use dir as overriding location
  if(Sys.getenv("WS_PATH") != "" & !new_path ) {
    ws_path <- Sys.getenv("WS_PATH")
  }
  
  if (ws_path == file.path(tempdir(), "ws_db")) {
    
    message(
      sprintf(
        "Creating temporary HWSD v2.0 file location at:\n %s", ws_path )
    )
    
    # create storage path
    if (!dir.exists(ws_path)) {
      dir.create(ws_path, recursive = TRUE)
    }
    
  } else {
    
    if (!dir.exists(ws_path)) {
      stop(
        "Database directory does not exist, please create the directory first!"
      )
    } else {
      Sys.setenv("WS_PATH" = ws_path)
      message(
        sprintf(
          "Saving HWSD v2.0 files in at:\n %s", ws_path )
      )
    }
  }
  
  # grab urls
  urls <- server(version = "2.0")
  
  # download zipped gridded data
  message("Downloading raster file")
  curl::curl_download(
    urls$grid,
    destfile = file.path(ws_path, "hwsd2_raster.zip"),
    quiet = TRUE
  )
  
  unzip(
    file.path(ws_path, "hwsd2_raster.zip"),
    exdir = ws_path
  )
  
  # clean up zip files
  status <- file.remove(
    c(
      file.path(ws_path, "hwsd2_raster.zip")
    )
  )
  
  # exit statement
  message("Downloaded HWSD v2.0 files")
}