# url <- "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_basic&resultType=results&viewParams=where%3Adatasetid+IN+%288045%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted&outputFormat=csv"
# extract_viewparams(url)
extract_viewparams <- function(url = NULL){
  if(is.null(url)) return(NULL)
  parsed_url <- httr::parse_url(url)
  
  stopifnot("query" %in% names(parsed_url))
  stopifnot("viewParams" %in% names(parsed_url$query))
  
  viewparams <- parsed_url$query$viewParams
  
  return(build_encode(viewparams))

}