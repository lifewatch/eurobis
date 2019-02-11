#' REMODnet BIO datasets
#'
#' This function lists all datasets you can download using REMODnet BIO package
#' @import dplyr imis
#' @export
#' @examples
#' listemodnetdatasets()



listemodnetdatasets <- function() {
  
  dasids<-datasetsSpecialCollection(619) %>% select(DasID,StandardTitle,EngAbstract)
  

  return(dasids)
  
}