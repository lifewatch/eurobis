test_that("eurobis_occurrences", {
  skip_if_offline()
  skip_on_cran()
  skip_on_ci()
  
  
  test1 <- eurobis_occurrences("basic", dasid = 8045)
  test2 <- eurobis_occurrences("full", dasid = 8045)
  test3 <- eurobis_occurrences("full_and_parameters", dasid = 8045)
  
  test <- list(test1, test2, test3)
  
  for(i in 1:length(test)){
    is_sf_df <- is(test[[i]], c("sf", "data.frame"))
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
  
  test <- eurobis_occurrences("basic", dasid = 8045)
  test_handler <- eurobis_sf_df_handler(test)
  expect_true(is(test_handler, c("sf")))
  
  
})