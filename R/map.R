#' Interactive map with Marine Regions products on your viewer. Click to get the MRGID and more info
#'
#' @param layer c('eez', 'iho', 'eez_iho'). See details.
#'
#' @return A leaflet map with Marine Regions product that retrieves info by clicking
#' @export
#'
#' @details These are Marine Regions products. Find more information in {https://marineregions.org/}
#' - eez = Exclusive Economic Zone
#' - iho = International Hydrographic Office areas
#' - eez_iho = Intersection of the EEZ and IHO areas
#' 
#' @examples 
#' \dontrun{
#' eurobis_map_mr('eez')
#' eurobis_map_mr('iho')
#' eurobis_map_mr('eez_iho')
#' }
eurobis_map_mr <- function(layer = 'eez'){
  mr_wms <- "http://geo.vliz.be/geoserver/MarineRegions/wms?"
  
  # Assertions
  stopifnot(layer %in% c('eez', 'iho', 'eez_iho'))
  stopifnot(length(layer) == 1)
  http_status <- httr::status_code(httr::HEAD(paste0(mr_wms, "request=GetCapabilities")))
  httr::stop_for_status(http_status)
  
  # Perform
  mr_map <- eurobis_base_map() %>%
    leaflet.extras2::addWMS(
      baseUrl = mr_wms,
      layers = layer,
      options = leaflet::WMSTileOptions(
        transparent = TRUE,
        format = "image/png",
        info_format = "text/html"
      ),
      attribution = shiny::HTML("<a href='https://marineregions.org/'>Marine Regions</a>") 
    ) %>% add_labels()
  
  return(mr_map)
}

#' Draw interactively a polygon and get it as Well Known Text
#'
#' @return a string with a polygon as Well Known Text
#' @export
#'
#' @examples 
#' \dontrun{wkt <- eurobis_map_draw()}
eurobis_map_draw <- function(){
  if(!interactive()) NULL
  
  base_map <- eurobis_base_map() %>% add_labels()
  
  polygon <- mapedit::editMap(
    base_map, 
    editorOptions = list(
      polylineOptions = FALSE, markerOptions = FALSE, circleOptions = FALSE, 
      circleMarkerOptions = FALSE,
      singleFeature = TRUE
    ), 
    title = "Click on the toolbar on the left to start drawing your area of interest. Click Done when you have finished.",
    crs = 4326
  )$all
  
  # Assertions
  if(is.null(polygon)) stop("No polygon was created")
  if(nrow(polygon) > 1){
    polygon <- sf::st_combine(polygon)
  }
  
  wkt <- sf::st_as_text(sf::st_geometry(polygon))
  
  message(wkt)
  return(wkt)
}

eurobis_base_map <- function(){
  emodnet_tiles <-"https://tiles.emodnet-bathymetry.eu/2020/baselayer/inspire_quad/{z}/{x}/{y}.png"
  
  # Assertions
  z=1;x=1;y=1
  http_status <- httr::status_code(httr::HEAD(glue::glue(emodnet_tiles)))
  httr::stop_for_status(http_status)
  
  # Perform
  base_map <- leaflet::leaflet(
    options = leaflet::leafletOptions(crs = leaflet::leafletCRS("L.CRS.EPSG4326"))
  ) %>%
    leaflet::addTiles(
      urlTemplate = emodnet_tiles, 
      options = leaflet::tileOptions(tms = FALSE),
      attribution = shiny::HTML("<a href='https://emodnet.ec.europa.eu'>EMODnet</a>") 
    )
  
  return(base_map)
}

add_labels <- function(map){
  emodnet_labels <- "https://tiles.emodnet-bathymetry.eu/osm/labels/inspire_quad/{z}/{x}/{y}.png"
  map %>%
    leaflet::addTiles(urlTemplate = emodnet_labels,
                      options = leaflet::tileOptions(tms = FALSE)
    ) %>%
    leaflet::setView(15, 45, zoom = 2)
}
