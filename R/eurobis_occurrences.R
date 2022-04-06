#' Get EurOBIS data by using the EMODnet-Biology webservices
#'
#' @param type Type of data, one of c('basic', 'full', 'full_and_parameters'). 
#' More info at: https://www.emodnet-biology.eu/emodnet-data-format
#' @param mrgid Marine Regions Gazetteer unique identifier
#' @param bbox Bounding box of the region of interest as WKT. If another type of feature is provided, the bounding box is calculated automatically
#' @param dasid IMIS dataset unique identifier
#' @param startdate Start date of occurrences
#' @param enddate End date of occurrences
#' @param aphiaid WoRMS taxon unique identifier
#' @param paging If TRUE, the data will be requested on chunks. Use for large requests.
#' @param paging_length Size of chunks in number of rows. Default 50K
#' @param ... Any parameters to pass to ows4r getFeature() (e.g. cql_filter or parallel)
#'
#' @return
#' @export
#'
#' @examples 
#' test <- eurobis_occurrences("basic", dasid = 8045, mrgid = c(5688, 5686))
#' test <- eurobis_occurrences("full", dasid = 8045)
#' test <- eurobis_occurrences("full_and_parameters", dasid = 8045)
#' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "Zostera marina")
#' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = c("Zostera marina", "foo"))
#' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "foo")
#' test <- eurobis_occurrences("basic", dasid = 8045, scientificname = "Zostera marina", aphiaid = 145795)
eurobis_occurrences <- function(type, 
                                mrgid = NULL, bbox = NULL, dasid = NULL, 
                                startdate = NULL, enddate = NULL, 
                                aphiaid = NULL, 
                                scientificname = NULL,
                                paging = FALSE, paging_length = 50000, ...){
  # Handle Scientific name
  if(!is.null(aphiaid) & !is.null(scientificname)){
    warning("Both aphiaid and scientificname provided: Ignoring scientificname")
  }else if(!is.null(scientificname)){
    aphiaid <- eurobis_name2id(scientificname)
  }
  
  # WFS
  wfs_client <- eurobis_wfs_client_init()
  info_layer <- eurobis_wfs_find_layer(wfs_client, type)
  
  # Print info
  info_msg <- paste0("Downloading the ", info_layer$getTitle(), ". ", info_layer$getAbstract())
  message(info_msg)
  
  # Add filters
  viewparams <- build_viewparams(mrgid, bbox, dasid, startdate, enddate, aphiaid)
  
  eurobis_data <- info_layer$getFeatures(viewParams = viewparams, resultType="results",
                                         paging = paging, paging_length = paging_length, 
                                         ...)
  
  eurobis_data <- eurobis_sf_df_handler(eurobis_data)
  
  return(eurobis_data)
}



# Base url - change if ever data changes of place
eurobis_wfs_url <- function(){
  "https://geo.vliz.be/geoserver/Dataportal/wfs"
}

# Returns the layer name in geoserver given one of the three types
# eurobis_type_handler("basic")
# eurobis_type_handler("full")
# eurobis_type_handler("full_and_parameters")
eurobis_type_handler <- function(type){
  possible_types <- c(basic = "Dataportal:eurobis-obisenv_basic", 
                      full = "Dataportal:eurobis-obisenv_full", 
                      full_and_parameters = "Dataportal:eurobis-obisenv")
  # Assertions
  stopifnot(length(type) == 1)
  
  is_wrong_type = !(type %in% names(possible_types))
  if(is_wrong_type){
    possible_types_collapsed <- paste0(names(possible_types), collapse = ", ")
    stop(paste0("type must be one of: ", possible_types_collapsed))
  }
  
  # Perform
  layer_name <- subset(possible_types, names(possible_types) == type)
  return(layer_name)
}


# Starts WFS client
eurobis_wfs_client_init <- function(logger = "INFO"){
  service <- eurobis_wfs_url()
  
  # Assertions
  stopifnot(curl::has_internet())
  emodnet_webservice_status <- httr::HEAD(service)
  httr::stop_for_status(emodnet_webservice_status)
  
  # Perform
  wfs_client <- ows4R::WFSClient$new(service, "2.0.0" #, logger = logger
                                     )
  wfs_client
}

# Get layer info
eurobis_wfs_find_layer <- function(wfs_client, type){
  type <- eurobis_type_handler(type)
  
  caps <- wfs_client$getCapabilities()
  info_layer <- caps$
    findFeatureTypeByName(type)
  
  info_layer
}


# Handle sf and data.frame objects
eurobis_sf_df_handler <- function(sf_df){
  stopifnot(is(sf_df, c("sf", "data.frame")))
  
  names(sf_df) <- tolower(names(sf_df))
  
  is_not_sf <- !is(sf_df, c("sf"))
  
  if(is.data.frame(sf_df) & is_not_sf){
    coords_exists <- "decimallatitude" %in% names(sf_df) & "decimallatitude" %in% names(sf_df)
    stopifnot(coords_exists)
    
    if(coords_exists){
      sf_df <- sf::st_as_sf(sf_df, coords = c("decimallongitude", "decimallatitude"), crs = 4326)
    }
    
  }
  
  return(sf_df)
}
