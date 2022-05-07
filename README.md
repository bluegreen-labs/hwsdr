# hwsdr

[![R-CMD-check](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml)
[![codecov](https://codecov.io/gh/bluegreen-labs/hwsdr/branch/main/graph/badge.svg?token=GQ2TENDJP6)](https://codecov.io/gh/bluegreen-labs/hwsdr)
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

To install the development releases of the package run the following
commands:

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("bluegreen-labs/hwsdr")
library("hwsdr")
```

Vignettes are not rendered by default, if you want to include additional
documentation please use:

``` r
if(!require(devtools)){install.packages("devtools")}
devtools::install_github("bluegreen-labs/hwsdr", build_vignettes = TRUE)
library("hwsdr")
```

## Use

### Single pixel location download

Get world soil values for a single site using the following format, specifying coordinates as a pair of latitude, longitude coordinates. Here all available soil layers are queried.

``` r
  all <- ws_subset(
    site = "HWSD",
    location = c(34, -81),
    param = "ALL"
  )
```

### Gridded data

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
##  Parameters

By default all parameters are downloaded, a complete list of the individual parameters is provided on the ORNL webpage (<https://daac.ornl.gov/SOILS/guides/HWSD.html>). Alternatively you may find a similar list of data in the `hwsd_meta_data` dataset as provided by the package.

## References

Wieder, W.R., J. Boehnert, G.B. Bonan, and M. Langseth. 2014. Regridded Harmonized World Soil Database v1.2. Data set. Available on-line from Oak Ridge National Laboratory Distributed Active Archive Center, Oak Ridge, Tennessee, USA. (<https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1247>).

## Acknowledgements

This project was supported by the Schmidt Futures Initiative Land Ecosystem Models based On New Theory, obseRvations, and ExperimEnts (LEMONTREE) project.
