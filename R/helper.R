#' Browse the LifeWatch/EMODnet-Biology Download Toolbox on your browser
#'
#' @return NULL, only opens the Download Toolbox in your browser.
#' @export
#'
#' @examples eurobis_download_toolbox()
eurobis_download_toolbox <- function(){
  url <- eurobis_url$info$toolbox
  req <- httr::HEAD(url)
  httr::stop_for_status(req)
  
  if(interactive()){
    message("The LifeWatch/EMODnet-Biology Download Toolbox provides a web interface to fine tune the selection of data from EurOBIS. At the end of the selection there is a button named \"Get webservice url\". Copy&Paste this URL into eurobis_occurrences(url = \"<URL>\"). Press ENTER to continue:" )
    readline("")
    utils::browseURL(url)
  }
  
  NULL
}
