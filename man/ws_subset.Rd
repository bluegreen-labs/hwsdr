% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ws_subset.R
\name{ws_subset}
\alias{ws_subset}
\title{Subset ORNL DAAC HWSD data}
\usage{
ws_subset(
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
)
}
\arguments{
\item{location}{location of a bounding box c(lon, lat, lon, lat) defined
by a bottom-left and top-right coordinates, a single location (lon, lat)}

\item{site}{sitename for the extracted location}

\item{param}{soil parameters to provide, the default setting is ALL, this 
will download all available soil parameters.Check
https://daac.ornl.gov/SOILS/guides/HWSD.html for parameter descriptions.}

\item{layer}{which soil depth layer of HWSD v2.0 to consider, layers are
named D1 to D7 from top to bottom}

\item{path}{path where to download the data to (only applicable to
spatial data)}

\item{ws_path}{path to the gridded HWSD v2.0 data, only required/used if
querying v2.0 data}

\item{internal}{do not store the data on disk}

\item{rate}{request rate in seconds, determines how long to wait between 
queries to avoid bouncing because of rate limitations}

\item{version}{version of HWSD to query (numeric value). By default the
package will query the ORNL DAAC v1.2 via their API. If specifying the
later version (2.0) it will download or require the gridded spatial data
in addition to the included HWSD v2.0 database with soil parameters.}

\item{verbose}{verbose output during processing, only covers the internal
use of the ws_download() function for HWSD v2.0 data}
}
\value{
Local geotiff data, or a data frame with HWSD soil information
}
\description{
Subset function to query pixel or spatial data from the
ORNL DAAC HWSD THREDDS server. Returns a tidy data frame
for point locations or raster data to the workspace or
disk.
}
\examples{

\dontrun{
 # extract sand fraction values
 # for a point location
 values <- ws_subset(
    site = "HWSD",
    location = c(34, -81),
    param = "T_SAND"
   )
   
 print(values)
 
 # Download a soil fraction map
 # of sand for a given bounding box
 t_sand <- ws_subset(
    site = "HWSD",
    location = c(32, -81, 34, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = TRUE
   )
   
 terra::plot(t_sand)
}
}
