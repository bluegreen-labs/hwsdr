# server end points
server <- function(
  version = "1.2"  
  ){
  
  # fao AWS base url
  fao_base <- "https://s3.eu-west-1.amazonaws.com/data.gaezdev.aws.fao.org" 
  
  if (version == "1.2") {
    # return ORNL DAAC url for HWSD v1.2
    url <- "https://thredds.daac.ornl.gov/thredds/ncss/ornldaac/1247"
    return(url)  
  } else {
    # return both files for HWSD v2.0
    url <- list(
      mdb = file.path(fao_base, "HWSD/HWSD2_DB.zip"),
      grid = file.path(fao_base, "HWSD/HWSD2_RASTER.zip")
    )
    return(url)  
  }
}
