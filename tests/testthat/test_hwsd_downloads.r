context("test hwsd routines")

test_that("checks...",{
  skip_on_cran()
  
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81, 32, -80),
    param = "ALL",
    path = tempdir(),
    internal = TRUE
  )
  
  expect_s4_class(data, "Raster")
  
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81, 32, -80),
    param = "ALL",
    path = tempdir(),
    internal = FALSE
  )
  
  
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81),
    param = "ALL"
  )
  
  expect_s3_class(data, "data.frame")
  
})