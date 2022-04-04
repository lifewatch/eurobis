test_that("Maps work", {
  skip_if_offline()
  skip_on_cran()
  
  base_map <- eurobis_base_map() %>% add_labels()
  base_is_leaflet <- "leaflet" %in% class(base_map)
  expect_true(base_is_leaflet)
  
  for(mr in c("eez", "iho", "eez_iho")){
    mr_map <- eurobis_mr_map(mr)
    mr_is_leaflet <- "leaflet" %in% class(mr_map)
    expect_true(mr_is_leaflet)
  }
})
