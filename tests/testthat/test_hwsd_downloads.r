context("test hwsd routines")

test_that("check bbox download ",{
  skip_on_cran()
  
  # check normal download to R session
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81, 32, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = TRUE
  )
  
  expect_s4_class(data, "Raster")
})  


test_that("check download to disk.",{
  skip_on_cran()
  
  # check download to disk
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81, 32, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = FALSE
  )
  
  expect_true(file.exists(file.path(tempdir(), "HWSD.tif")))
})


test_that("check point download",{
  skip_on_cran()
  
  # check point extraction
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81),
    param = "ALL"
  )
  
  expect_s3_class(data, "data.frame")
})

test_that("check coordinate length",{
  skip_on_cran()
  
  # check normal download to R session
  expect_error(
    ws_subset(
      site = "HWSD",
      location = c(34, -81, 32),
      param = "T_SAND",
      path = tempdir(),
      internal = TRUE
    )
  )
  
})  

test_that("faulty param",{
  skip_on_cran()
  
  # check normal download to R session
  expect_error(
    ws_subset(
      site = "HWSD",
      location = c(34, -81, 32, -80),
      param = "T_SANL",
      path = tempdir(),
      internal = TRUE
    )
  )
})  


