#' Get EurOBIS data by using the EMODnet-Biology webservices
#'
#' @param type Type of data, one of c('basic', 'full', 'full_and_parameters'). Alternatively you 
#' can use one of the wrappers:
#' 
#' - \code{\link{eurobis_occurrences_basic}}
#' - \code{\link{eurobis_occurrences_full}}
#' - \code{\link{eurobis_occurrences_full_and_parameters}}
#' 
#' More info at: \url{https://www.emodnet-biology.eu/emodnet-data-format}
#' @param url A WFS request copied from the LifeWatch/EMODnet-Biology Download Toolbox. Use \code{\link{eurobis_download_toolbox}}
#' @param mrgid Marine Regions Gazetteer unique identifier. See list of available regions with \code{\link{eurobis_list_regions}} and 
#' visualize with \code{\link{eurobis_map_regions}}
#' @param geometry a WKT geometry string or sf object with the region of interest. You can draw a polygon interactively 
#' with \code{\link{eurobis_map_draw}}
#' @param dasid IMIS dataset unique identifier. See list of available datasets with \code{\link{eurobis_list_datasets}}
#' @param start_date Start date of occurrences. Format YYYY-MM-DD.
#' @param end_date End date of occurrences. Format YYYY-MM-DD.
#' @param aphiaid WoRMS taxon unique identifier. See \url{https://www.marinespecies.org/} and \url{https://docs.ropensci.org/worrms/}
#' @param scientific_name Taxon name. It is matched with WoRMS on the fly. Ignored if aphiaid is provided.
#' @param functional_groups Functional groups available in WoRMS: See \code{eurobis::species_traits}.
#' @param cites CITES Annex. See \code{eurobis::species_traits}.
#' @param habitats_directive Habitats Directive Annex. See \code{eurobis::species_traits}.
#' @param iucn_red_list IUCN Red List Category. See \code{eurobis::species_traits}.
#' @param msdf_indicators Marine Strategy Directive Framework indicators. See \code{eurobis::species_traits}.
#' @param paging If TRUE, the data will be requested on chunks. Use for large requests.
#' @param paging_length Size of chunks in number of rows. Default 50K.
#' @param ... Any parameters to pass to  \code{ows4R} get feature request (e.g. cql_filter or parallel)
#'
#' @return a tibble or sf object with eurobis data
#'
#' @details 
#' Set \code{options(verbose = TRUE)} to display more information
#'
#' @examples \dontrun{
#' # Get dataset with ID 8045
#' # See also ?eurobis_list_datasets
#' test <- eurobis_occurrences_basic(dasid = 8045)
#' 
#' # Get full dataset with ID 8045
#' test <- eurobis_occurrences_full(dasid = 8045)
#' 
#' # Get full dataset with ID 8045 including extra measurements or facts 
#' test <- eurobis_occurrences_full_and_paremeters(dasid = 8045)
#' 
#' # Get occurrences from Zostera marina in the ecoregion Alboran Sea (MRGID 21897)
#' # See also ?eurobis_list_regions
#' test <- eurobis_occurrences_full(mrgid = 21897, scientific_name = "Zostera marina")
#' 
#' # Get zooplankton occurrences from the region of your choice
#' # See ?eurobis_map_mr and ?eurobis::species_traits
#' my_area <- eurobis_map_draw()
#' test <- eurobis_occurrences_basic(geometry = my_area, functional_groups = "zooplankton")
#' 
#' # Get occurrences from the Continuous Plankton Recorder (dataset id 216) in January 2016
#' test <- eurobis_occurrences_basic(dasid = 216, start_date = "2016-01-01", end_date = "2016-01-31")
#' }
eurobis_occurrences <- function(type,
                                url = NULL,
                                mrgid = NULL, 
                                geometry = NULL, 
                                dasid = NULL, 
                                start_date = NULL, end_date = NULL, 
                                aphiaid = NULL, scientific_name = NULL,
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
    viewparams <- build_viewparams(mrgid, geometry, dasid, start_date, end_date, aphiaid, 
                                   functional_groups, cites, habitats_directive,
                                   iucn_red_list, msdf_indicators)
  }
  
  # Handle Scientific name
  if(!is.null(aphiaid) & !is.null(scientific_name)){
    warning("Both aphiaid and scientific_name provided: Ignoring scientific_name")
  }else if(!is.null(scientific_name)){
    aphiaid <- eurobis_name2id(scientific_name)
  }
  
  # WFS
  wfs_client <- eurobis_wfs_client_init()
  info_layer <- eurobis_wfs_find_layer(wfs_client, type)
  
  # Print info
  if(getOption("verbose")){
    # message(cat("\n", "\n"))
     cli::cli_alert_success("Downloading layer: {info_layer$getTitle()}")
     cli::cli_alert_info("{info_layer$getAbstract()}")
  }

  
  # Perform
  eurobis_data <- info_layer$getFeatures(viewParams = viewparams, resultType="results",
                                         paging = paging, paging_length = paging_length, 
                                         ...)
  
  
  
  if(nrow(eurobis_data) == 0){
    warning("There are 0 occurrences in EurOBIS for this query at the moment")
  }else{
    eurobis_data <- eurobis_sf_df_handler(eurobis_data)
  }
  
  return(eurobis_data)
}

#' @rdname eurobis_occurrences
#' @export
eurobis_occurrences_basic <- function(...){
  eurobis_occurrences(type = "basic", ...)
}

#' @rdname eurobis_occurrences
#' @export
eurobis_occurrences_full <- function(...){
  eurobis_occurrences(type = "full", ...)
}

#' @rdname eurobis_occurrences
#' @export
eurobis_occurrences_full_and_parameters <- function(...){
  eurobis_occurrences(type = "full_and_parameters", ...)
}

# Returns the layer name in geoserver given one of the three types
# eurobis_type_handler("basic")
# eurobis_type_handler("full")
# eurobis_type_handler("full_and_parameters")
eurobis_type_handler <- function(type){
  possible_types <- unlist(eurobis_url$datatypes)
  
  # Assertions
  stopifnot(length(type) == 1)
  checkmate::assert_choice(type, names(possible_types))
  
  # Perform
  layer_name <- subset(possible_types, names(possible_types) == type)
  return(layer_name)
}


# Starts WFS client
eurobis_wfs_client_init <- function(logger = "INFO"){
  service <- eurobis_url$dataportal$wfs
  
  # Assertions
  stopifnot(curl::has_internet())
  
  httr2::request(service) %>%
    httr2::req_url_path_append("request=GetCapabilities") %>%
    httr2::req_method("HEAD") %>%
    httr2::req_user_agent(string_user_agent) %>%
    httr2::req_perform() %>%
    httr2::resp_check_status()
  
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
  stopifnot(any(c("sf", "data.frame") %in% base::class(sf_df)))
    
  names(sf_df) <- tolower(names(sf_df))
  
  is_not_sf <- !methods::is(sf_df, c("sf"))
  
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
    
  sf::st_crs(sf_df) <- 4326
  
  return(sf_df)
}
