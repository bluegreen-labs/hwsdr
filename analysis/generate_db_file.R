# Convert Microsoft Access database file to an
# R serialized dataframe for inclusion in the
# package (only the grid layout will be 
# downloaded externally to the package)
# 
# The data returned by this routine will also
# only cover the main soil type, not the associated
# soil types.
#
# This data is included in the package as the main
# database is provided in a proprietary format which
# is difficult to read without additional tools.

library(dplyr)

#---- define MS Access reading function ----

# This function requires mdbtools to be installed
# on the system that runs the code (either linux
# or macOS).
# 
# on Ubuntu run: sudo apt install mdbtools

mdb_read <- function(file)
{
  
  tables = c(
    "HWSD2_LAYERS",
    "HWSD2_SMU"
  )
  
  # dump database content to temporary file
  df <- lapply(tables, function(table){
    
    f <- tempfile()
    system2(
      command = 'mdb-export',
      args = paste('-b strip', file, shQuote(table)),
      stdout = f
    )
    
    # read in CSV file
    data <- readr::read_csv(f)
    
    if (table == "HWSD2_SMU") {
      data <- data |>
        dplyr::select(
          HWSD2_SMU_ID,
          WRB4
        ) |>
        rename(
          'WRB_main' = 'WRB4'
        )
    }
    
    # return mdb data of sub-table
    data
  })
  
  # left join both tables on common HWSD2_SMU_ID
  # and filter the main WRB (dominant soil layer)
  # from the data
  df <- do.call("left_join", df) |>
    dplyr::filter(
      WRB4 == WRB_main
    ) |>
    select(
      -WRB_main
    )
  
  # return the whole data frame
  return(df)
}

#---- download MS access HWSD v2.0 database ----
# 
# if(!dir.exists("./data-raw")) {
#   dir.create("./data-raw")
# }
# 
# curl::curl_download(
#   unlist(server(version = "2.0")$mdb),
#   destfile = "./data-raw/HWSD2.zip"
# )
# 
# unzip(
#   "./data-raw/HWSD2.zip",
#   exdir = "./data-raw/"
#   )
# 
# file.remove("./data-raw/HWSD2.zip")

#---- grab the database values for tables ----

db <- mdb_read("./data-raw/HWSD2.mdb")

# save as rda object
#saveRDS(db, "data/hwsd2.rda", compress = "xz")

