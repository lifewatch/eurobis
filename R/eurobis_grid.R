eurobis_grid <- function(grid_size, datasetid = NULL, 
                         aphiaid = NULL){
  
  # Sanity check
  if(is.null(datasetid) & is.null(aphiaid)){
    stop("Please provide a datasetid or an aphiaid", call. = FALSE)
  }
  
  
  
  # Change the name of the filters and put in a viewparams
  base_url <- eurobis_url$dataportal$wms
  viewparams = "&viewparams="
  
  if(!is.null(datasetid)){
    # Assertion
    dasid_in_list <- any(datasetid  %in% eurobis_list_datasets()$id)
    if(!dasid_in_list){
      stop(glue::glue("datasetid {datasetid} is not in `eurobis_list_datasets()`"), call. = FALSE)
    }
    
    datasetid = paste0("imis_dasid:", datasetid)
  }
  
  if(!is.null(aphiaid)){
    aphiaid = paste0("AphiaID:", aphiaid)
  }
  
  query <- paste0(c(datasetid, aphiaid), collapse = ";")
  
  base_url_filter <- paste0(eurobis_url$dataportal$wms, "viewparams=", query)
  
  
  
  
  # Get layer name
  layer_name <- gsub("Dataportal:", "", subset(eurobis_url$grid, names(eurobis_url$grid) == grid_size), fixed = TRUE)
  
  # Get Layer info
  
  # Display WMS layer
  grid_map <- eurobis_base_map() %>%
    leaflet.extras2::addWMS(
      baseUrl = base_url_filter,
      layers = layer_name,
      options = leaflet::WMSTileOptions(
        transparent = TRUE,
        format = "image/png",
        info_format = "text/html"
      ),
      attribution = shiny::HTML("<a href='https://eurobis.org/'>EurOBIS</a>")
    )
  
  return(grid_map)
}
# debug(eurobis_grid)
# eurobis_grid("1d", "8045")


# 
# 
# "https://geo.vliz.be/geoserver/wms?TRANSPARENT=true&LAYERS=Eurobis:eurobis_grid
# &VIEWPARAMS=tablename:1d;imis_dasid:8045;AphiaID:495077&STYLES=eurobis_orange&SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=application/openlayers&SRS=EPSG:4326&BBOX=-43.339999999851,1.660000000149,1.660000000149,46.660000000149&WIDTH=256&HEIGHT=256"
# 
# build_grid_viewparams <- function(grid_size, datasetid = NULL, aphiaid = NULL){
#   wms <- "https://geo.vliz.be/geoserver/wms?TRANSPARENT=true&LAYERS=Eurobis:eurobis_grid"
# }
# 
# 
# library(magrittr)
# test <- eurobis:::eurobis_base_map() %>%
#   leaflet.extras2::addWMS(
#     baseUrl = "http://geo.vliz.be/geoserver/Dataportal/wms?VIEWPARAMS=imis_dasid:8045",
#     layers = "eurobis_grid_1d-obisenv",
#     options = leaflet::WMSTileOptions(
#       transparent = TRUE,
#       format = "image/png",
#       info_format = "text/html"
#     ),
#     attribution = shiny::HTML("<a href='https://marineregions.org/'>Marine Regions</a>")
#   )
# 
# test