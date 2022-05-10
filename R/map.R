#' Interactive map with the regions on your viewer. Click to get the MRGID and more info
#'
#' @param layer The region or place type to be displayed. See details.
#'
#' @return A leaflet map with the regions that retrieves info by clicking
#'
#' @details 
#' To select a specific layer you have to provide the code for the layer. These are:
#' - Marine Ecoregion of the World (MEOW) = "ecoregions"
#' - IHO Sea Area = "iho"
#' - EEZ = "eez"
#' - Marine Region = "eez_iho"
#' - EMODnet Biology Reporting Areas = "reportingareas"
#' 
#' Marine Regions {https://marineregions.org/} is the geographical backbone of EurOBIS. 
#' All the regions are included in the Marine Regions Gazetteer. You can see the full list of regions 
#' with eurobis_list_regions(). 
#' 
#' You can find more info about these layers in {https://marineregions.org/sources.php}
#' 
#' The EMODnet Biology Reporting Areas are not described there. The EMODnet Reporting Areas are modified 
#' from the MSDF European seas (https://www.eea.europa.eu/data-and-maps/data/europe-seas-1) to fit the 
#' purpose of reporting in the EMODnet project. More info 
#' in: \url{https://marineregions.org/gazetteer.php?p=details&id=63392}
#'
#' @examples 
#' \dontrun{
#' eurobis_map_regions_ecoregions()
#' eurobis_map_regions_eez()
#' eurobis_map_regions_iho()
#' eurobis_map_regions_eez_iho()
#' eurobis_map_regions_reportingareas()
#' }
eurobis_map_regions <- function(layer = 'eez'){
  
  # Assertions
  checkmate::assert_character(layer)
  checkmate::assert_choice(layer, names(eurobis_url$mr_layers))
  stopifnot(length(layer) == 1)
  
  # Config
  layer <- subset(eurobis_url$mr_layers, names(eurobis_url$mr_layers) == layer)
  layer <- strsplit(layer[[1]], ":", TRUE)[[1]]
  namespace <- layer[1]
  layer <- layer[2]
  wms <- glue::glue("http://geo.vliz.be/geoserver/{namespace}/wms?")
  
  # Server check
  httr2::request(wms) %>%
    httr2::req_url_path_append("request=GetCapabilities") %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent(string_user_agent) %>%
    httr2::req_perform() %>%
    httr2::resp_check_status()
  
  # Perform
  mr_map <- eurobis_base_map() %>%
    leaflet.extras2::addWMS(
      baseUrl = wms,
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

#' @rdname eurobis_map_regions
#' @export
eurobis_map_regions_ecoregions <- function(){
  eurobis_map_regions('ecoregions')
}

#' @rdname eurobis_map_regions
#' @export
eurobis_map_regions_eez <- function(){
  eurobis_map_regions('eez')
}

#' @rdname eurobis_map_regions
#' @export
eurobis_map_regions_iho <- function(){
  eurobis_map_regions('iho')
}

#' @rdname eurobis_map_regions
#' @export
eurobis_map_regions_eez_iho <- function(){
  eurobis_map_regions('eez_iho')
}

#' @rdname eurobis_map_regions
#' @export
eurobis_map_regions_reportingareas <- function(){
  eurobis_map_regions('reportingareas')
}


#' Draw interactively a polygon and get it as Well Known Text
#'
#' @return a string with a polygon as Well Known Text
#' @export
#'
#' @details 
#' Set \code{options(verbose = TRUE)} to display more information
#' 
#' @examples 
#' \dontrun{wkt <- eurobis_map_draw()}
eurobis_map_draw <- function(){
  if(!interactive()) NULL
  
  if(getOption("verbose")){
    cli::cli_alert_success("Running Shiny App on localhost")
    cli::cli_ul("Draw polygon interactively on viewer pane")
  }
  
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
  
  if(getOption("verbose")) cli::cli_alert_info(wkt)
  
  message(wkt)
  return(wkt)
}

eurobis_base_map <- function(){
  emodnet_tiles <-"https://tiles.emodnet-bathymetry.eu/2020/baselayer/inspire_quad/{z}/{x}/{y}.png"
  
  # Assertions
  z=1;x=1;y=1
  url_test <- glue::glue(emodnet_tiles)
  url_not_up <- httr2::request(url_test) %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent(string_user_agent) %>%
    httr2::req_perform() %>% 
    httr2::resp_is_error()
  
  if(url_not_up){
    cli::cli_alert_danger("Connection to {url_test} failed")
    cli::cli_alert_warning("Check status of https://portal.emodnet-bathymetry.eu/")
    return()
  }
  
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
