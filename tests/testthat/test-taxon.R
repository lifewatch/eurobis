test_that("Taxon match works", {
  skip_if_offline()
  ok <- is.numeric(eurobis_name2id(c("Abra alba", "Engraulis encrasicolus")))
  expect_true(ok)
  
  expect_error(eurobis_name2id(c("foo")))
  expect_error(eurobis_name2id(1))
  expect_error(eurobis_name2id(""))
  
  expect_error(eurobis_name2id(c("Abra alba", "foo", NA)))
})
