#' Browse the LifeWatch/EMODnet-Biology Download Toolbox on your browser
#'
#' @return NULL, only opens the Download Toolbox in your browser.
#' @export
#'
#' @examples eurobis_download_toolbox()
eurobis_download_toolbox <- function(){
  if(interactive()){
    url <- eurobis_url$info$toolbox
    
    # Sanity Check
    url_not_up <- httr2::request(url) %>%
      httr2::req_method("HEAD") %>%
      httr2::req_user_agent(string_user_agent) %>%
      httr2::req_perform() %>% 
      httr2::resp_is_error()
  
    if(url_not_up) cli::cli_alert_danger("Connection to {url} failed.")
  
  
    cli::cli_alert_success("Connecting to {url}") 
    cli::cli_alert_info("The LifeWatch/EMODnet-Biology Download Toolbox provides a web interface to fine tune the selection of data from EurOBIS. At the end of the selection there is a button named \"Get webservice url\". Copy&Paste this URL into eurobis_occurrences(url = \"<URL>\"). Press ENTER to continue:" )
    readline("")
    utils::browseURL(url)
  }else{
    NULL
  }
}

#' List EurOBIS datasets
#'
#' @return a tibble with the dataset ID and the dataset title that can be queried with the 
#' eurobis package. See details section.
#' @export
#' 
#' @details 
#' The datasets of EurOBIS are documented in the Integrated Marine Information System (IMIS)
#' If you want to get more information about a dataset, you can look up the dataset 
#' in https://www.vliz.be/en/imis?module=dataset.
#' 
#' Note you can pass the dataset ID to the url. e.g: 
#' https://www.vliz.be/en/imis?module=dataset&dasid=216 
#' 
#' If you prefer a machine-readable format, add `&show=json`
#' https://www.vliz.be/en/imis?module=dataset&dasid=216&show=json
#' 
#' You can read this easily in R, e.g:
#' jsonlite::fromJSON("https://www.vliz.be/en/imis?module=dataset&dasid=216&show=json")
#'
#' @examples eurobis_list_datasets()
eurobis_list_datasets <- function(){
  eurobis_list("datasets")
}


#' List Marine Regions 
#'
#' @return a tibble with the Marine Regions names and unique identifier MRGID. See details section.
#'
#' @details 
#' The Marine Regions Gazetteer is the geographical backbone of EurOBIS.
#' 
#' The MRGID is the Marine Regions Gazetteer Unique Identifier. This is a persistent ID that won't be ever deleted. 
#' See https://marineregions.org/mrgid.php for further information.
#' 
#' You can find more info about each marine region by searching in the Marine Regions website: 
#' https://marineregions.org/gazetteer.php?p=search
#' 
#' Or you can use the mregion2 R package (on development): 
#' https://github.com/lifewatch/mregions2
#' 
#' E.g.:
#' mregions2::mr_gaz_record(25600)
#' 
#' @examples \dontrun{eurobis_list_regions()}
eurobis_list_regions <- function(){
  out <- eurobis_list("regions")
  out$nameNL <- NULL
  out
}


# Helper to get list of emodnet biology datasets
# and queriable marine regions
# the traits are not really working atm
eurobis_list <- function(type){
  # Sanity check
  checkmate::assertChoice(type, c("datasets", "regions", "traits"))
  
  # Config
  url <- glue::glue("{eurobis_url$info$toolbox_api_endpoint}{type}")
  
  # Request
  resp <- httr2::request(url) %>%
    httr2::req_user_agent(string_user_agent) %>%
    httr2::req_perform() %>%
    httr2::resp_body_json()
  
  out <- resp$data

  if(is.list(out)){
    out <- as.data.frame(do.call(rbind, resp$data))
    out <- apply(out, 2, unlist)
  }  
  
  tibble::as_tibble(out)
}

string_user_agent <- glue::glue("eurobis {packageVersion('eurobis')}; {R.version.string[1]}; {R.version$platform[1]}")





