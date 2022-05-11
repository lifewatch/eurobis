#' Get the WoRMS AphiaID given a scientific name
#'
#' @param taxa The scientific name of a taxon registered in the World Rercord of Marine Species
#'
#' @return a vector of AphiaID
#' @export
#'
#' @examples \dontrun{
#' eurobis_name2id(c("Abra alba", "Engraulis encrasicolus"))
#' eurobis_name2id(c("foo"))
#' eurobis_name2id(1)
#' eurobis_name2id("")
#' eurobis_name2id(c("Abra alba", "foo", NA))
#' eurobis_name2id(c("Abra alba", "Engraulis encrasicolus"))
#' eurobis_name2id(c("abra alba", "foo foo2", "caballo loco"))
#' }
eurobis_name2id <- function(taxa){
  stopifnot(is.character(taxa))
  taxa_are_not_empty <- !any(taxa %in% c("", NA_character_))
  stopifnot(taxa_are_not_empty)
  
  # Encode spaces as plus symbols
  taxa_encoded <- gsub(" ", "+", taxa, fixed = TRUE)
  taxa_encoded <- lapply(taxa_encoded, utils::URLencode, reserved = TRUE) %>% unlist()
  taxa_dictionary <- data.frame(taxa, taxa_encoded, stringsAsFactors = FALSE)
  
  # Perform
  aphiaid <- suppressWarnings(worrms::wm_name2id_(taxa_encoded)) %>% unlist()
  
  if(is.null(aphiaid)){
    stop("None of the taxa were found")
  }
  
  # Check
  taxa_are_not_found <- !(assertthat::are_equal(length(taxa), length(aphiaid)))
  
  if(taxa_are_not_found){
    names_not_found <- subset(taxa_dictionary$taxa, !(taxa_dictionary$taxa_encoded %in% names(aphiaid))) %>%
      paste0(collapse = ", ") 
    warning(paste0("The following taxa were not found: ", names_not_found), call. = FALSE)
  }
  
  # Format
  decoded_taxa_names <- subset(taxa_dictionary$taxa, taxa_dictionary$taxa_encoded %in% names(aphiaid))
  names(aphiaid) <- decoded_taxa_names
  
  return(aphiaid)
}














