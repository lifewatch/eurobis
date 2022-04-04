test_that("viewParams are build correctly", {
  # Dataset
  dataset_is_char <- is.character(build_filter_dataset(216))
  expect_true(dataset_is_char)
  
  # Geo
  wkt <- 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))'

  geo_ok_both <- is.character(build_filter_geo(mrgid = 8364, bbox = wkt))
  expect_true(geo_ok_both)
  
  geo_ok_mrgid <- is.character(build_filter_geo(mrgid = 8364))
  expect_true(geo_ok_mrgid)
  
  geo_ok_mrgids <- is.character(build_filter_geo(mrgid = c(8364, 8365)))
  expect_true(geo_ok_mrgids)
  
  geo_ok_wkt <- is.character(build_filter_geo(bbox = wkt))
  expect_true(geo_ok_wkt)
  expect_error(build_filter_geo(bbox = "This is not WKT"))
  
  test_df <- sf::st_as_sf(data.frame(wkt = wkt), wkt = "wkt")
  expect_error(build_filter_geo(bbox = test_df))
  sf::st_crs(test_df) <- 4326
  geo_ok_sf <- is.character(build_filter_geo(bbox = test_df))
  expect_true(geo_ok_sf)
  
  test_bbox <- sf::st_bbox(test_df)
  geo_ok_bbox <- is.character(build_filter_geo(test_bbox))
  expect_true(geo_ok_bbox)
  
  # Dates
  date_ok_char <- is.character(build_filter_time("1990-01-01", "2020-01-01"))
  expect_true(date_ok_char)
  
  date_ok_date <- is.character(build_filter_time(as.Date("1990-01-01"), "2020-01-01"))
  expect_true(date_ok_date)
  
  expect_error(build_filter_time("2020-01-01", "1990-01-01"))
  expect_error(build_filter_time(NULL, "1990-01-01"))
  expect_error(build_filter_time("2020-01-01", NULL))
  expect_null(build_filter_time())
  
  # Taxon c(104108, 148947)
  aphia_ok_int <- is.character(build_filter_aphia(104108))
  expect_true(aphia_ok_int)
  
  aphia_ok_char <- is.character(build_filter_aphia("104108"))
  expect_true(aphia_ok_char)
  
  expect_warning(build_filter_aphia(104108.5))
  expect_null(build_filter_aphia())
  
  # All together
  is_character <- is.character(
    build_viewparams(mrgid = 8364, bbox = wkt, 
                     dasid = 216, startdate = "2000-01-01", enddate = "2022-01-31", 
                     aphiaid = c(104108, 148947))
  )
  expect_true(is_character)
  
  expect_null(suppressWarnings(build_viewparams()))
  expect_warning(build_viewparams())
  
})
