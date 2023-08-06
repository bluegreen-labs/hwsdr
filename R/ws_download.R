#' Download HWSD v2.0 data
#'
#' Downloads both the database and gridded HWSD v2.0 data products
#' to a desired output path for subsetting.
#'
#' @param ws_path the path / directory where to store the HWSD v2.0 database
#' @param new_path update the path, i.e. dowload data to a new local
#'  location (logical, default FALSE)
#'
#' @return current data path
#' @export
#'
#' @examples

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
  
  # download zipped database from FAO
  message("Downloading database file")
  curl::curl_download(
    urls$mdb,
    destfile = file.path(ws_path, "hwsd2_db.zip"),
    quiet = TRUE
  )
  
  unzip(
    file.path(ws_path, "hwsd2_db.zip"),
    exdir = ws_path
  )
  
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
      file.path(ws_path, "hwsd2_raster.zip"),
      file.path(ws_path, "hwsd2_db.zip")
    )
  )
  
  # exit statement
  message("Downloaded HWSD v2.0 files")
}