#' Get EurOBIS data by using the EMODnet-Biology webservices
#'
#' @param type Type of data, one of c('basic', 'full', 'full_and_parameters'). 
#' More info at: https://www.emodnet-biology.eu/emodnet-data-format
#' @param url A WFS request copied from the LifeWatch/EMODnet-Biology Download Toolbox. Use eurobis_download_toolbox()
#' @param mrgid Marine Regions Gazetteer unique identifier
#' @param geometry a WKT geometry string or sf object with the region of interest.
#' @param dasid IMIS dataset unique identifier.
#' @param startdate Start date of occurrences.
#' @param enddate End date of occurrences.
#' @param aphiaid WoRMS taxon unique identifier.
#' @param paging If TRUE, the data will be requested on chunks. Use for large requests.
#' @param paging_length Size of chunks in number of rows. Default 50K.
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
#' test <- eurobis_occurrences("full", dasid = 8045, functional_groups = "angiosperms")
eurobis_occurrences <- function(type, 
                                url = NULL,
                                mrgid = NULL, 
                                geometry = NULL, 
                                dasid = NULL, 
                                startdate = NULL, enddate = NULL, 
                                aphiaid = NULL, scientificname = NULL,
                                functional_groups = NULL, 
                                cites = NULL, 
                                habitats_directive = NULL,
                                iucn_red_list = NULL, 
                                msdf_indicators = NULL,
                                paging = FALSE, paging_length = 50000, ...){
  
  # Add filters
  if(!is.null(url)){
    viewparams <- extract_viewparams(url)
  }else if(is.null(url)){
    viewparams <- build_viewparams(mrgid, geometry, dasid, startdate, enddate, aphiaid, 
                                   functional_groups, cites, habitats_directive,
                                   iucn_red_list, msdf_indicators)
  }
  
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
  
  # Perform
  eurobis_data <- info_layer$getFeatures(viewParams = viewparams, resultType="results",
                                         paging = paging, paging_length = paging_length, 
                                         ...)
  
  eurobis_data <- eurobis_sf_df_handler(eurobis_data)
  
  if(nrow(eurobis_data) == 0) warning("There are 0 occurrences in EurOBIS for this query at the moment")
  
  return(eurobis_data)
}


# Returns the layer name in geoserver given one of the three types
# eurobis_type_handler("basic")
# eurobis_type_handler("full")
# eurobis_type_handler("full_and_parameters")
eurobis_type_handler <- function(type){
  possible_types <- unlist(eurobis_url$datatypes)
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
  service <- eurobis_url$dataportal$wfs
  
  # Assertions
  stopifnot(curl::has_internet())
  emodnet_webservice_status <- httr::HEAD(service)
  httr::stop_for_status(emodnet_webservice_status)
  
  # Perform
  wfs_client <- ows4R::WFSClient$new(service, "2.0.0" #, logger = logger
                                     )
  return(wfs_client)
}

# Get layer info
eurobis_wfs_find_layer <- function(wfs_client, type){
  type <- eurobis_type_handler(type)
  
  caps <- wfs_client$getCapabilities()
  info_layer <- caps$
    findFeatureTypeByName(type)
  
  return(info_layer)
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
      
      if(nrow(sf_df) == 0){
        sf_df <- suppressWarnings(
          sf::st_as_sf(sf_df, coords = c("decimallongitude", "decimallatitude"), remove = FALSE)
        )
      }else{
        sf_df <- sf::st_as_sf(sf_df, coords = c("decimallongitude", "decimallatitude"), remove = FALSE)
      }
      
    }
    
  }
  
  if("geometry" %in% names(sf_df)) sf_df <- sf_df %>% rename(the_geom = geometry)
  if("geom" %in% names(sf_df)) sf_df <- sf_df %>% rename(the_geom = geom)
  
  sf::st_crs(sf_df) <- 4326
  
  return(sf_df)
}
