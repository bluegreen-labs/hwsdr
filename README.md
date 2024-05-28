# hwsdr

[![R-CMD-check](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/bluegreen-labs/hwsdr/branch/main/graph/badge.svg?token=GQ2TENDJP6)](https://app.codecov.io/gh/bluegreen-labs/hwsdr)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/hwsdr)](https://cran.r-project.org/package=hwsdr)
[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/hwsdr)](https://cranlogs.r-pkg.org/badges/grand-total/hwsdr)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.6527648.svg)](https://doi.org/10.5281/zenodo.6527648)

Programmatic interface to the Harmonized World Soil Database 'HWSD' web services (<https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1247>). Allows for easy downloads of 'HWSD' soil data directly to your R workspace or your computer. Routines for both single pixel data downloads and gridded data are provided.

## How to cite this package in your article

> Koen Hufkens. (2022). bluegreen-labs/hwsdr: CRAN release (v1.0). Zenodo. https://doi.org/10.5281/zenodo.6527648

## Installation

### stable release

To install the current stable release use a CRAN repository:

```r
install.packages("hwsdr")
library("hwsdr")
```

### development release

> Breaking change: as of version 1.1 the order of the coordinates in the
location string has changed from (lat, lon, lat, lon) to (lon, lat, lon, lat)!

To install the development releases of the package run the following
commands:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/hwsdr")
library("hwsdr")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(remotes)){install.packages("remotes")}
remotes::install_github("bluegreen-labs/hwsdr", build_vignettes = TRUE)
library("hwsdr")
```

## Use

### HWSD v1.2 (ORNL DAAC API)

#### Single pixel location download

Get world soil values for a single site using the following format, specifying coordinates as a pair of latitude, longitude coordinates. Here all available soil layers are queried.

``` r
all <- ws_subset(
    site = "HWSD",
    location = c(-81, 34),
    param = "ALL"
  )
```

#### Gridded data

You can download gridded data by specifying a bounding box c(lat, lon, lat, lon) defined by a bottom left and top right coordinates. Here the call only extracts the top soil fraction of sand (% weight).

``` r
t_sand <- ws_subset(
    site = "HWSD",
    location = c(32, -81, 34, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = TRUE
  )
```
###  Parameters

By default all parameters are downloaded, a complete list of the individual parameters is provided on the ORNL webpage (<https://daac.ornl.gov/SOILS/guides/HWSD.html>). Alternatively you may find a similar list of data in the `hwsd_meta_data` dataset as provided by the package.

### HWSD v2.0 (FAO)

This is an experimental feature, awaiting an update of the ORNL DAAC API to version 2.0 of the HWSD database. Although functionally complete the procedure is more complex as it includes a bulk download of a base map.

#### Download the base map

The HWSD v2.0 data is distributed as a gridded spatial map where homogeneous regions are indicated with indices (integers). Although the underlying database is included in the package and can be accessed using `hwsdr::hwsd2`, the spatial data accompanying the database is too large for inclusion in the package. This spatial data needs to be downloaded explicitly to a desired path before any other functions will work.

``` r
# set the ws_path variable using a FULL path name
path <- ws_download(
  ws_path = "/your/full/path",
  verbose = TRUE
)
```

### Single pixel location download

Get world soil values for a single site using the following format, specifying coordinates as a pair of longitude, latitude coordinates (longitude, latitude). Here the call only extracts the top soil (layer = "D1") fraction of sand and silt (% weight) for one specific location. Note that you will need to specify the correct version to be used in processing.

``` r
values <- ws_subset(
    site = "HWSD_V2",
    location = c(-81, 34),
    param = c("SAND","SILT"),
    layer = "D1",
    version = "2.0", # set correct HWSD version
    ws_path = "/your/full/path" # specify grid map directory
  )
```

### Gridded data

You can grab gridded data by specifying a bounding box c(lon, lat, lon, lat) defined by a bottom left and top right coordinates. Here the call only extracts the top soil (D1 layer) fraction of sand (%).

``` r
sand <- ws_subset(
    location = c(32, -81, 34, -80),
    param = "SAND",
    layer = "D1",
    version = "2.0",
    ws_path = Sys.getenv("WS_PATH"),
    # ws_path = "/your/full/path",
    internal = TRUE
  )
```

## References

Wieder, W.R., J. Boehnert, G.B. Bonan, and M. Langseth. 2014. Regridded Harmonized World Soil Database v1.2. Data set. Available on-line from Oak Ridge National Laboratory Distributed Active Archive Center, Oak Ridge, Tennessee, USA. (<https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1247>).

## Acknowledgements

The `hwsdr` package is a product of BlueGreen Labs, and has been in part supported by the LEMONTREE project funded through the Schmidt Futures fund, under the umbrella of the Virtual Earth System Research Institute (VESRI).
