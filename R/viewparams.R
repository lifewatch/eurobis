# Encodes an URL except the plus symbol
# This is a workaround
build_encode <- function(query){
  query_encoded <- URLencode(query, reserved = TRUE)
  query_encoded_with_plus <- gsub(URLencode("+", T), "+", query_encoded, fixed = TRUE)
  return(query_encoded_with_plus)
}

#' String that can be passed to viewParams 
#'
#' @param mrgid Marine Regions Gazetteer unique identifier
#' @param bbox Bounding box of the region of interest as WKT. If another type of feature is provided, the bounding box is calculated automatically
#' @param dasid IMIS dataset unique identifier
#' @param startdate Start date of occurrences
#' @param enddate End date of occurrences
#' @param aphiaid WoRMS taxon unique identifier
#'
#' @return a string that can be passed to viewParams in a WFS request to EMODnet-Biology
#' @export
#'
#' @examples 
#' build_viewparams()
#' build_viewparams(mrgid = 8364)
#' build_viewparams(bbox = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
#' build_viewparams(mrgid = 8364, bbox = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
#' build_viewparams(dasid = 216)
#' build_viewparams(dasid = 216, startdate = "2000-01-01", enddate = "2022-01-31")
#' build_viewparams(mrgid = 8364, bbox = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))', 
#'                  dasid = 216, startdate = "2000-01-01", enddate = "2022-01-31", aphiaid = c(104108, 148947))
build_viewparams <- function(mrgid = NULL, bbox = NULL, dasid = NULL, 
                             startdate = NULL, enddate = NULL, aphiaid = NULL){
  
  filters <- c(
    build_filter_geo(mrgid, bbox),
    build_filter_dataset(dasid),
    build_filter_time(startdate, enddate)
  )
  
  filter_aphia <- build_filter_aphia(aphiaid)
  
  no_filters <- is.null(filters) & is.null(filter_aphia)
  
  if(no_filters){
    warning("No filters were applied")
    return(NULL)
  }
  
  query <- paste0(filters, collapse = "+AND+")
  query <- paste0("where:", query, ";context:0100", filter_aphia)
  # message(query)
  query <- build_encode(query)
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



# Creates a filter by mrgid or spatial with a bbox or polygon that can be used in viewParams in a WFS request
# mrgid must be a character vector with mrgids
# bbox must be a WKT string with the bbox
# build_filter_geo()
# build_filter_geo(8364)
# build_filter_geo(bbox = 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
# build_filter_geo(8364, 'POLYGON((-2 52,-2 58,9 58,9 52,-2 52))')
build_filter_geo <- function(mrgid = NULL, bbox = NULL){
  if(is.null(mrgid) & is.null(bbox)){
    return(NULL)
  }
  
  base <- URLencode("(", T)
  mrgid_query <- NULL
  bbox_query <- NULL
  
  if(!is.null(mrgid)){
    mrgid <- paste0(mrgid, collapse = "\\,")
    mrgid_query <- paste0("(up.geoobjectsids+&&+ARRAY[", mrgid, "])")
  }
  
  if(!is.null(bbox)){
    stopifnot(wellknown::validate_wkt(bbox)$is_valid)
  
    bbox <- gsub(",", "\\,", bbox, fixed = TRUE)
    bbox_query <- paste0("(ST_Intersects(ST_Envelope(ST_SetSRID(ST_GeomFromText('", bbox, "')\\,4326))\\,+up.the_geom))")
  }
  
  if(is.null(mrgid_query)){
    query <- paste0("(", bbox_query, ")")
  }else if(is.null(bbox_query)){
    query <- paste0("(", mrgid_query, ")")
  }else{
    query <- paste(mrgid_query, bbox_query, sep = "+OR+")
    query <- paste0("(", query, ")")
  }
  
  return(query)
  
}


# Creates a filter given an start and end date that can be used in viewParams in a WFS request
# build_filter_time()
# build_filter_time(as.Date("2000-01-01"), "2022-01-31")
# build_filter_time(NULL, "2022-01-31")
# build_filter_time("2000-01-01", NULL)
build_filter_time <- function(startdate = NULL, enddate = NULL){
  
  dates <- list(startdate, enddate)
  
  dates_are_null <- unlist(lapply(dates, is.null))
  if(all(dates_are_null)) return(NULL)
  if(any(dates_are_null)) stop("Both startdate and enddate must be provided or ignored")
  
  dates_asserted <- lapply(lapply(dates, as.Date), as.character)
  
  query <- paste0(
    "((observationdate+BETWEEN+'",
    dates_asserted[[1]],
    "'+AND+'",
    dates_asserted[[2]],
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
  if(are_double) warning("AphiaID provided as double coerced into integer with trunc()")
  
  aphiaid_as_char <- as.character(aphiaid_trunc)
  aphiaid_collapsed <- paste0(aphiaid_as_char, collapse = "\\,")
  
  query <- paste0(";aphiaid:", aphiaid_collapsed)
  return(query)
}


## Other filter that won't be created as it will bring further confusion
## We can get these by asking the user to parse an WFS request url from the EMODnet-Biology Download Toolbox
## and choosing only the viewParams query
## We can also give the option of passing cql_filters with vendor params

## season NOPE
# +AND+((observationdate+BETWEEN+'2000-01-01'+AND+'2022-01-31'+AND+seasonID+IN+(2\\,3)))

## Taxon rank - NOPE
# +AND+taxonrank+>=+180

## Time precision - NOPE
# +AND+time_precision+>=+10

## Coordinate precision - NOPE
# +AND+(false+OR+coordinateprecision_category+=+0+OR+coordinateprecision_category+=+1)

## Certain measurement types
# +AND+measurement_type_group_ids+&&+ARRAY[19\\,46]

## Taxon attributes - NOPE
# +AND+aphiaid+IN+(+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+selectid+IN+('zooplankton'\\,'Zooplankton'\\,'phytoplankton'\\,'Benthos'))