#' Eurobis datasets
#'
#' This function lists all datasets you can download using the eurobis package
#' @import dplyr imis
#' @export
#' @examples
#' listeurobisdatasets()



listeurobisdatasets <- function() {
  
  dasids<-datasetsSpecialCollection(619) %>% select(DasID,StandardTitle,EngAbstract)
  

  return(dasids)
  
}