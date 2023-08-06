context("test hwsd v2 routines")

test_that("check download to disk.",{
  skip_on_cran()
  data <- ws_subset(
    site = "HWSD",
    location = c(-81, 34),
    param = "SAND",
    layer = "D1",
    version = "2.0"
  )
  
  expect_type(data, "list")
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
    ws_subset(
      param = "SAND",
      layer = "D1",
      version = "2.0"
    )
  
  expect_s4_class(data, "SpatRaster")
})
