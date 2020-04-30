#' Get data from EurOBIS as points
#'
#' This function allows you to download a summary geospatial grid, summarizing the number of eurobis occurrences using a species (aphiaID) and grid size
#' @param aphiaid The taxon id obtained throug www.marinespecies.org (or the r package 'worrms')
#' @import dplyr imis reshape2 sf
#' @export
#' @examples
#' getEurobisPoints(aphiaid = "141433")
#' test_points <- getEurobisPoints()
#' mapview(test_points, cex = 1)

getEurobisPoints <- function(aphiaid = 126436){

  Eurobispoints <- st_read(paste0('http://geo.vliz.be/geoserver/wfs/ows?',
                                  'service=WFS&version=1.3.0&',
                                  'request=GetFeature&',
                                  'typeName=Dataportal%3Aeurobis_points-obisenv&',
                                  'viewParams=aphiaid%3A', aphiaid, '&',
                                  'outputFormat=json'))

}

