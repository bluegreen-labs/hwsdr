#' HWSD meta-data
#'
#' Data frame with meta-data on the ORNL DAAC parameters one can query
#' using the THREDDS server. In addition a brief description of the
#' various data products and their units is provided.
#' 
#' @format data.frame
#' \describe{
#'   \item{parameter}{parameter names used in THREDDS server call}
#'   \item{subset}{bands within a data product (only for CLM data)}
#'   \item{description}{general description of the variable}
#'   \item{units}{units of the variable}
#' }
"hwsd_meta_data"