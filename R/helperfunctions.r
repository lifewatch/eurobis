#' add collunms to data frame
#' @export


fncols <- function(data, cname) {
  add <-cname[!cname%in%names(data)]
  if(length(add)!=0) data[add] <- as.character(NA)
  data
}


substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

#' get the rightmost characters from a string
#' @export

richtfrom <- function(x, y, n = 0) {
  substrRight(x, nchar(x)-stringr::str_locate(x, y)[1] - n)
  }

#' get the mid characters from a string
#' @export

sectioninstring <- function(text, starchar, n, endchar, m) {
  substr(text, stringr::str_locate(text, starchar)[1] - n, stringr::str_locate(text, endchar)[1] - m) }


#'
eventhierarchy <- c("cruise", "stationVisit", "sample", "subsample", "eventID")


#' remove empty collumns and make all collumns into characters
#' @export

cleandataframe <- function (x) {
  
  x[x =='NA' | x =='' | x ==' '] <- NA
  x <- x[,colSums(is.na(x))<nrow(x)]
  x <- data.frame(lapply(x, as.character), stringsAsFactors=FALSE)

}