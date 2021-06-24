# hwsdr

[![R-CMD-check](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/bluegreen-labs/hwsdr/actions/workflows/R-CMD-check.yaml)

Programmatic interface to the Harmozied World Soil Database 'HWSD' web services (<https://daac.ornl.gov/cgi-bin/dsviewer.pl?ds_id=1247>). Allows for easy downloads of 'HWSD' soil data directly to your R workspace or your computer. Routines for both single pixel data downloads and gridded (netCDF) data are provided.

## Installation

### stable release

To install the current stable release use a CRAN repository:

``` r
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
devtools::install_github("bluegreen-labs/daymetr", build_vignettes = TRUE)
library("hwsdr")
```

## Use

### Single pixel location download

Get world soil values for a single site using the following format

``` r
ws_subset(
		site = "Oak Ridge National Laboratories",
                lat = 36.0133,
                lon = -84.2625,
                start = 1980,
                end = 2010,
                internal = TRUE)
```

#### *netCDF subset (ncss) data*

``` r
ws_subset(location = c(36.61,-85.37,33.57,-81.29),
                     start = 1980,
                     end = 1980,
                     param = "tmin")
```

## Citation


## Acknowledgements

This project was supported by the ....

