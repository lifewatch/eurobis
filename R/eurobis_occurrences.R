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
#' test <- eurobis_occurrences("basic", dasid = 8045)
#' test <- eurobis_occurrences("full", dasid = 8045)
#' test <- eurobis_occurrences("full_and_parameters", dasid = 8045)
eurobis_occurrences <- function(type, 
                                mrgid = NULL, bbox = NULL, dasid = NULL, 
                                startdate = NULL, enddate = NULL, aphiaid = NULL, 
                                paging = FALSE, paging_length = 50000, ...){
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
  
  return(eurobis_data)
}


# test <- eurobis_occurrences("basic", dasid = 8045)


# Base url - change if ever data changes of place
eurobis_wfs_url <- function(){
  "https://geo.vliz.be/geoserver/Dataportal/wfs"
}

# Returns the layer name in geoserver given one of the three types
# eurobis_type_handler("basic")
# eurobis_type_handler("full")
# eurobis_type_handler("full_and_parameters")
eurobis_type_handler <- function(type){
  # Dict - layer names in geoserver
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


# wfs_client <- eurobis_wfs_client_init()
# 
# obisenv_basic <- eurobis_obisenv_basic()
# 
# info_layer <- eurobis_wfs_find_layer(wfs_client, obisenv_basic)
# 
# info_layer$getTitle()
# info_layer$getAbstract()
# 
# crs <- info_layer$getDefaultCRS()


