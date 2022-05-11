# Encodes an URL except the plus symbol
# This is a workaround
build_encode <- function(query){
  query_encoded <- utils::URLencode(query, reserved = TRUE)
  query_encoded_with_plus <- gsub(utils::URLencode("+", T), "+", query_encoded, fixed = TRUE)
  return(query_encoded_with_plus)
}

# String that can be passed to viewParams
# 
# build_viewparams()
# build_viewparams(mrgid = 8364)
# build_viewparams(polygon = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
# build_viewparams(mrgid = 8364, polygon = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
# build_viewparams(dasid = 216)
# build_viewparams(dasid = 216, start_date = "2000-01-01", end_date = "2022-01-31")
# build_viewparams(mrgid = 8364, polygon = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))',
#                  dasid = 216, start_date = "2000-01-01", end_date = "2022-01-31",
#                  aphiaid = c(104108, 148947))
build_viewparams <- function(mrgid = NULL, geometry = NULL, dasid = NULL, 
                             start_date = NULL, end_date = NULL, aphiaid = NULL, 
                             functional_groups = NULL, cites = NULL, habitats_directive = NULL,
                             iucn_red_list = NULL, msdf_indicators = NULL
                             ){
  
  filters <- c(
    build_filter_geo(mrgid, geometry),
    build_filter_dataset(dasid),
    build_filter_time(start_date, end_date),
    build_filter_traits(functional_groups, cites, habitats_directive, 
                        iucn_red_list, msdf_indicators)
  )
  
  filter_aphia <- build_filter_aphia(aphiaid)
  
  no_filters <- is.null(filters) & is.null(filter_aphia)
  
  if(no_filters){
    warning("No filters were applied", call. = FALSE)
    return(NULL)
  }
  
  query <- paste0(filters, collapse = "+AND+")
  query <- paste0("where:", query, ";context:0100", filter_aphia)
  # message(query)
  query <- build_encode(query)
  # 
  # # Assert length
  # too_long <- nchar(query) < 2000
  # 
  # if(too_long){
  #   stop("Large queries are not yet supported. Please reduce the number of possible values.")
  # }
  # 
  return(query)
}

# Creates a filter by dasid that can be used in viewParams in a WFS request
# build_filter_dataset()
# build_filter_dataset(6667)
build_filter_dataset <- function(dasid = NULL){
  if(is.null(dasid)) return(NULL)
  
  dasid <- paste0(dasid, collapse = "\\,")
  query <- paste0("datasetid+IN+(", dasid, ")")
  return(query)
}



# Creates a filter by mrgid or spatial with a polygon or polygon that can be used in viewParams in a WFS request
# mrgid must be a character vector with mrgids
# polygon must be a WKT string or sf object
# build_filter_geo()
# build_filter_geo(8364)
# build_filter_geo(polygon = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
# build_filter_geo(8364, 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
build_filter_geo <- function(mrgid = NULL, polygon = NULL){
  if(is.null(mrgid) & is.null(polygon)){
    return(NULL)
  }
  
  base <- utils::URLencode("(", T)
  mrgid_query <- NULL
  polygon_query <- NULL

  # Assertions mrgid
  if(!is.null(mrgid)){
    mrgid <- paste0(mrgid, collapse = "\\,")
    mrgid_query <- paste0("(up.geoobjectsids+&&+ARRAY[", mrgid, "])")
  }
  
  # Assertions polygon
  if(!is.null(polygon)){
    is_sf <- "sf" %in% class(polygon)
    if(is_sf){
      no_crs <- is.na(sf::st_crs(polygon)$input)
      if(no_crs) stop(paste0("polygon: no coordinate projection system found - set with `sf::st_crs(polygon) <- 'EPGS:<code>'`"), call. = FALSE)
      
      is_4326 <- sf::st_crs(polygon)$input == "EPGS:4326" 
      if(!is_4326){
        message("polygon: sf object projection is not 4326 - transforming coordinates to EPGS:4326")
        polygon <- sf::st_transform(polygon, 4326)
      }
      
      
    }
    
    is_bbox <- "bbox" %in% class(polygon)
    if(is_bbox){
      polygon <- sf::st_as_text(sf::st_as_sfc(polygon))
    }
    
    if(is.character(polygon)){
      is_valid_wkt <- wk::wk_problems(wk::new_wk_wkt(polygon))
      if(!is.na(is_valid_wkt)) stop(glue::glue("Invalid WKT string: {is_valid_wkt}"), call. = FALSE)
      
      polygon <- sf::st_as_sfc(polygon)
    }
    
    
    
    # Geometry collection check
    geom_type <- sf::st_geometry_type(polygon, by_geometry = FALSE)
    
    is_collection <- any(c("GEOMETRYCOLLECTION", "GEOMETRY") %in% geom_type)
    if(is_collection){
      message("Geometry supplied is of type 'GEOMETRYCOLLECTION'. Extracting only features of type 'POLYGON' or 'MULTIPOLYGON")
      
      polygon <- sf::st_collection_extract(
        polygon,
        type = "POLYGON",
        warn = TRUE
      )
    }
    
    if(length(polygon) > 1){
      polygon <- sf::st_combine(polygon)
    }
    
    polygon <- sf::st_as_text(sf::st_geometry(polygon))
    
    # Assert length polygon
    too_long <- nchar(polygon) > 1500
    if(too_long){
      stop("Complex geometries are not yet supported. Please reduce the number of vertices.", call. = FALSE)
    }
    
    # Perform
    polygon <- gsub(",", "\\,", polygon, fixed = TRUE)
    polygon_query <- paste0("(ST_Intersects(ST_SetSRID(ST_GeomFromText('", polygon, "')\\,4326)\\,+up.the_geom))")
  }
  
  if(is.null(mrgid_query)){
    query <- paste0("(", polygon_query, ")")
  }else if(is.null(polygon_query)){
    query <- paste0("(", mrgid_query, ")")
  }else{
    query <- paste(mrgid_query, polygon_query, sep = "+OR+")
    query <- paste0("(", query, ")")
  }
  return(query)
}







# Creates a filter given an start and end date that can be used in viewParams in a WFS request
# build_filter_time()
# build_filter_time(as.Date("2000-01-01"), "2022-01-31")
# build_filter_time(NULL, "2022-01-31")
# build_filter_time("2000-01-01", NULL)
build_filter_time <- function(start_date = NULL, end_date = NULL){
  
  dates <- list(start_date, end_date)
  
  dates_are_null <- unlist(lapply(dates, is.null))
  if(all(dates_are_null)) return(NULL)
  if(any(dates_are_null)) stop("Both start_date and end_date must be provided or ignored", call. = FALSE)
  
  dates_as_date <- lapply(dates, as.Date) 
  
  if(dates_as_date[[1]] > dates_as_date[[2]]) stop("start_date cannot be smaller than end_date", call. = FALSE)
  
  dates_as_char <- lapply(dates_as_date, as.character)
  
  query <- paste0(
    "((observationdate+BETWEEN+'",
    dates_as_char[[1]],
    "'+AND+'",
    dates_as_char[[2]],
    "'))"
  )
  return(query)
}

# Creates a filter given an aphiaid that can be used in viewParams in a WFS request
# build_filter_aphia()
# build_filter_aphia("148947")
# build_filter_aphia(148947)
# build_filter_aphia(148947.1)
# build_filter_aphia(c(104108, 148947))
build_filter_aphia <- function(aphiaid = NULL){
  if(is.null(aphiaid)) return(NULL)
  
  aphiaid_as_num <- as.numeric(aphiaid)
  aphiaid_trunc <- trunc(aphiaid_as_num)
  
  are_double <- any(aphiaid_as_num != aphiaid_trunc)
  if(are_double) warning("AphiaID provided as double. Coerced into integer with trunc()", call. = FALSE)
  
  aphiaid_as_char <- as.character(aphiaid_trunc)
  aphiaid_collapsed <- paste0(aphiaid_as_char, collapse = "\\,")
  
  query <- paste0(";aphiaid:", aphiaid_collapsed)
  return(query)
}

# functional_groups = NULL, 
# cites = NULL, 
# habitats_directive = NULL, 
# iucn_red_list = NULL, 
# msdf_indicators = NULL

## Taxon attributes
# build_filter_traits(
#   functional_groups = c("algae", "zooplankton"),
#   cites = "I",
#   habitats_directive = "IV",
#   iucn_red_list = c("data deficient", "least concern"),
#   msdf_indicators = "Black Sea proposed indicators"
# )
build_filter_traits <- function(functional_groups = NULL, cites = NULL, habitats_directive = NULL,
                                iucn_red_list = NULL, msdf_indicators = NULL
  ){
  
  traits = list(`Functional group` = functional_groups, 
                `CITES Annex` = cites, 
                `Habitats Directive Annex` = habitats_directive,
                `IUCN Red List Category` = iucn_red_list,
                `MSFD indicators` = msdf_indicators)
  
  traits <- purrr::compact(traits)
  if(length(traits) == 0) return(NULL)
  
  # Assertions
  traits_are_character <- all(unlist(lapply(traits, is.character)))
  stopifnot(traits_are_character)
  
  # Check values passed to traits
  for(i in 1:length(traits)){
      trait_name <- names(traits[i])
      accepted <- subset(eurobis::species_traits$selection, eurobis::species_traits$group == trait_name)
      not_accepted <- subset(traits[[i]], !(tolower(traits[[i]]) %in% tolower(accepted)))
      
      if(length(not_accepted) != 0){
        stop(glue::glue("Assertion on '{trait_name}' failed. Must be element of set {paste0(accepted, collapse = ', ')}"), call. = FALSE)
     }
  }
  
  # Perform
  traits <- tolower(unlist(traits))
  selectid <- subset(eurobis::species_traits$selectid, tolower(eurobis::species_traits$selection) %in% traits)
  selectid <- paste0("'", selectid, "'")
  selectid <- paste0(selectid, collapse = "\\,")
  
  query <- paste0(
    "aphiaid+IN+(+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+(",
    selectid,
    "))"
  )
  
  return(query)
  
}
