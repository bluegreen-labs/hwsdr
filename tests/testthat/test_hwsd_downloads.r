context("test hwsd routines")

test_that("check bbox download ",{
  skip_on_cran()
  data <- ws_subset(
    site = "HWSD",
    location = c(32, -81, 34, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = TRUE
  )
  
  expect_s4_class(data, "SpatRaster")
})  


test_that("check download to disk.",{
  skip_on_cran()
  data <- ws_subset(
    site = "HWSD",
    location = c(32, -81, 34, -80),
    param = "T_SAND",
    path = tempdir(),
    internal = FALSE
  )
  
  expect_true(file.exists(file.path(tempdir(), "HWSD.tif")))
})

test_that("check point download",{
  skip_on_cran()
  data <- ws_subset(
    site = "HWSD",
    location = c(34, -81),
    param = "ALL"
  )
  
  expect_s3_class(data, "data.frame")
})

test_that("check coordinate length",{
  skip_on_cran()
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

test_that("test sf bbox method",{
  skip_on_cran()
  a <- sf::st_sf(a = 1:2,
                geom = sf::st_sfc(
                  sf::st_point(c(34, -81)),
                  sf::st_point(c(32, -80))),
                crs = 4326)

  data <- a |>
    sf::st_bbox() |>
    ws_subset(param = "T_SAND")
  
  expect_s4_class(data, "SpatRaster")
})

test_that("faulty param (multiples)",{
  skip_on_cran()
  expect_error(
   ws_subset(
      site = "HWSD",
      location = c(34, -81),
      param = c("T_SAND", "T_SIT")
    )
  )
})

