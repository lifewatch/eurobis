test_that("eurobis_occurrences", {
  skip_if_offline()
  skip_on_cran()
  skip_on_ci()
  
  test1 <- eurobis_occurrences("basic", dasid = 8045)
  test2 <- eurobis_occurrences("full", dasid = 8045)
  test3 <- eurobis_occurrences("full_and_parameters", dasid = 8045)
  
  test <- list(test1, test2, test3)
  
  for(i in 1:length(test)){
    is_sf_df <- methods::is(test[[i]], c("sf", "data.frame"))
    expect_true(is_sf_df)
  }

  #' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "Zostera marina")
  #' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = c("Zostera marina", "foo"))
  #' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "foo")
  #' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "Zostera marina", aphiaid = 145795)
  
})


test_that("sf handler works fine", {
  skip_if_offline()
  skip_on_cran()
  skip_on_ci()
  
  
  pol_gibraltar <- 'POLYGON ((-6.102905 36.2026, -5.064697 36.21634, -5.039978 35.67239, -6.122131 35.65591, -6.204529 35.98832, -6.102905 36.2026))'
  
  test_ok <- eurobis_occurrences(
    "basic", 
    geometry = pol_gibraltar,
    startdate = "1990-01-01",
    enddate = "1995-12-31",
    functional_groups = "mammals" 
  )
  expect_true(methods::is(test_ok, "sf"))
  
  # Empty = no pisces
  expect_warning(
    eurobis_occurrences(
      "basic", 
      geometry = pol_gibraltar,
      startdate = "1990-01-01",
      enddate = "1995-12-31",
      functional_groups = "pisces" 
    )
  )
  
  
})

# 
# test_that("all filters perform as expected", {
#   skip_if_offline()
#   skip_on_cran()
#   skip_on_ci()
#   
#   
#   
#   
# })