context("test hwsd routines")

test_that("checks...",{
  skip_on_cran()
  
  data <- ws_subset(
    sitename = "HWSD",
    location = c(34, -81, 32, -80),
    param = "ALL",
    path = tempdir(),
    silent = FALSE,
    internal = FALSE
  )
  
  expect_s4_class(data, "Raster")
  
  data <- ws_subset(
    sitename = "HWSD",
    location = c(34, -81),
    param = "ALL"
  )
  
  expect_s3_class(data, "data.frame")
  
})