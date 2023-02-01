test_that("eurobis_occurrences", {
  skip_if_offline()
  skip_on_cran()
  skip_on_ci()
  
  test1 <- eurobis_occurrences_basic(dasid = 8045, count = 1, propertyname = "datasetid,decimallongitude,decimallatitude")
  test2 <- eurobis_occurrences_full(dasid = 8045, count = 1, propertyname = "datasetid,decimallongitude,decimallatitude")
  test3 <- eurobis_occurrences_full_and_parameters(dasid = 8045, count = 1, propertyname = "datasetid,decimallongitude,decimallatitude")
  
  test <- list(test1, test2, test3)
  
  lapply(test, expect_s3_class, class = "sf")
  
})

test_that("counts fun works", {
  skip_if_offline()
  skip_on_cran()
  skip_on_ci()
  
  count <- eurobis_occurrences_count(dasid = 8045, verbose = FALSE)
  
  total_exists <- "total" %in% colnames(count)
  expect_true(total_exists)
  expect_true(is.numeric(count$total))
})

test_that("sf handler works fine", {
  skip_on_cran()
  skip_on_ci()
  
  test_ok <- data.frame(decimallatitude = 1, decimallongitude = 1, 
                        stringsAsFactors = FALSE) %>%
    eurobis_sf_df_handler()

  expect_s3_class(test_ok, "sf")
  
  # Empty = no pisces
  # Need to add support for httptest mock up requests
  # .f <- function(){
  #   eurobis_occurrences(
  #     "basic", 
  #     geometry = pol_gibraltar,
  #     start_date = "1990-01-01",
  #     end_date = "1995-12-31",
  #     functional_groups = "pisces",
  #     count = 1
  #   )
  # }
  # 
  # expect_warning(.f())
  
})

