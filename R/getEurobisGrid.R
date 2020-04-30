#' Get data from EurOBIS as Gridded polygon values
#'
#' This function allows you to download a summary geospatial grid, summarizing the number of eurobis occurrences using a species (aphiaID) and grid size
#' @param aphiaid The taxon id obtained throug ww.marinespecies.org
#' @param gridsize The grid size of which you want to get you grid. Possible grid sizes are '6m', '15m', '30m', '1d' (6 minutes, 15 minutes, 30 minutes, 1 degree).
#' @import dplyr imis reshape2 sf
#' @export
#' @examples
#' getEurobisGrid(aphiaid = "141433")
#' 
#' test <- getEurobisGrid(gridsize = '15m')
#' library(mapview)
#' mapview(test,
#'         zcol = 'RecordCount',
#'         lwd = 0)


getEurobisGrid <- function(aphiaid = 126436, gridsize = '30m'){
    
  # add some test to verify input
  if (!gridsize %in% c('6m', '15m', '30m', '1d')) stop("gridsize should be '6m', '15m', '30m' or '1d'", call. = FALSE)
  
  # download directly as vector: 
  EurobisGrid <- st_read(paste0('http://geo.vliz.be/geoserver/wfs/ows?',
                                      'service=WFS&version=1.3.0&',
                                      'request=GetFeature&',
                                      'typeName=Dataportal%3Aeurobis_grid_',
                                      gridsize,
                                      '-obisenv&',
                                      'viewParams=aphiaid%3A', aphiaid, '&',
                                      'outputFormat=json'))

}
