test_that("viewParams are build correctly", {
  # Dataset
  dataset_is_char <- is.character(build_filter_dataset(216))
  expect_true(dataset_is_char)
  
  # Geo
  wkt <- 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))'
  wkt_collection <- 'GEOMETRYCOLLECTION (POLYGON ((-2 52, -2 58, 9 58, 9 52, -2 52)), POLYGON ((-2 52, -2 58, 9 58, 9 52, -2 52)))'
  wkt_wrong_geom <- 'GEOMETRYCOLLECTION (POINT (-2 52), POLYGON ((-2 52, -2 58, 9 58, 9 52, -2 52)))'
  
  polygon_fine <- sf::st_as_sfc(wkt)
  polygon_collection <- sf::st_geometrycollection(
    list(
      sf::st_point(c(1, 0)),
      sf::st_polygon(list(matrix(c(5.5, 7, 7, 6, 5.5, 0, 0, -0.5, -0.5, 0), ncol = 2)))
    )
  )

  geo_ok_both <- is.character(build_filter_geo(mrgid = 8364, polygon = wkt))
  expect_true(geo_ok_both)
  
  geo_ok_mrgid <- is.character(build_filter_geo(mrgid = 8364))
  expect_true(geo_ok_mrgid)
  
  geo_ok_mrgids <- is.character(build_filter_geo(mrgid = c(8364, 8365)))
  expect_true(geo_ok_mrgids)
  
  geo_ok_wkt <- is.character(build_filter_geo(polygon = wkt))
  expect_true(geo_ok_wkt)
  expect_error(build_filter_geo(polygon = "This is not WKT"))
  
  geo_ok_polygon <- is.character(build_filter_geo(polygon = polygon_fine))
  expect_true(geo_ok_polygon)
  
  geo_ok_polygon_collection <- is.character(build_filter_geo(polygon = polygon_collection))
  expect_true(geo_ok_polygon_collection)
  
  test_df <- sf::st_as_sf(data.frame(wkt = wkt), wkt = "wkt")
  expect_error(build_filter_geo(polygon = test_df))
  sf::st_crs(test_df) <- 4326
  geo_ok_sf <- is.character(build_filter_geo(polygon = test_df))
  expect_true(geo_ok_sf)
  
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
  
  # Traits
  traits_ok <- is.character(build_filter_traits(
    functional_groups = c("algae", "zooplankton"),
    cites = "I",
    habitats_directive = "IV",
    iucn_red_list = c("data deficient", "least concern"),
    msdf_indicators = "Black Sea proposed indicators"
  ))
  expect_true(traits_ok)
  expect_error(build_filter_traits("foo"))
  
  
  # All together
  is_character <- is.character(
    build_viewparams(mrgid = 8364, geometry = wkt, 
                     dasid = 216, startdate = "2000-01-01", enddate = "2022-01-31", 
                     aphiaid = c(104108, 148947),
                     functional_groups = c("algae", "zooplankton"),
                     cites = "I",
                     habitats_directive = "IV",
                     iucn_red_list = c("data deficient", "least concern"),
                     msdf_indicators = "Black Sea proposed indicators")
  )
  expect_true(is_character)
  
  expect_null(suppressWarnings(build_viewparams()))
  expect_warning(build_viewparams())
  
})

test_that("viewParams are correctly extracted from URL", {
  skip_if_offline()
  skip_on_cran()
  
  url <- "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3Adatasetid+IN+%288045%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv"
  test <- eurobis_occurrences("basic", url = url)
  
  expect_true(is(test, "sf"))
  
})
