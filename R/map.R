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
#' eurobis_mr_map('eez')
#' eurobis_mr_map('iho')
#' eurobis_mr_map('eez_iho')
eurobis_mr_map <- function(layer = 'eez'){
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

#' Title
#'
#' @return
#' @export
#'
#' @examples wkt <- eurobis_draw_bbox()
eurobis_draw_bbox <- function(){
  if(!interactive()) NULL
  
  base_map <- eurobis_base_map() %>% add_labels()
  
  rectangle <- mapedit::editMap(
    base_map, 
    editorOptions = list(
      polylineOptions = FALSE, markerOptions = FALSE, circleOptions = FALSE, 
      circleMarkerOptions = FALSE, polygonOptions = FALSE,
      singleFeature = TRUE
    ), 
    title = "Draw a rectangle",
    crs = 4326
  )$all
  
  # Assertions
  if(is.null(rectangle)) stop("No bounding box was created")
  if(nrow(rectangle) > 1) stop("Only one bounding box supported")
  
  wkt <- sf::st_as_text(sf::st_geometry(rectangle))
  
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
                      options = tileOptions(tms = FALSE)
    ) %>%
    leaflet::setView(15, 45, zoom = 2)
}
