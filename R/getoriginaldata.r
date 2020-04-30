#' Get original records from IPT based on EMODnet biology output   -  in development
#'
#' This function allows you to download the original data as provided from IPT using the EMODnet Biology download output
#' @param ipturls mandatory parameter, a vector containing one or more IPTURLS
#' @import dplyr finch RCurl
#' @export
#' @examples
#' getoriginaldata(ipturls = meta$datasetIPTurl)


getoriginaldata <- function (ipturls, eurobisdata = NA) {
  
  ipturls <- unique(ipturls[!is.na(ipturls)])
  ipturls <- ipturls[(ipturls != "")]
                                                      
  
  if  (length(ipturls) == 0) {print("no IPT links found")} else {
  for (link in ipturls) {
  
  if (grepl("resource?", link)==TRUE) {
    link <- gsub("resource?", "archive", link) }
  
    if ( ((grepl("archive?", link)==FALSE | url.exists(link) == FALSE)) & grepl(".zip", link) == FALSE)
    {
      print ("Link does not resolve to a public IPT resource")
    }  else   
    { 
 
    
    
    #-----------------------------------------------------------------------#
    ####                    Import data                                  ####
    #-----------------------------------------------------------------------#
    
    dwca_cache$delete_all()
    file <- link
    
    tryCatch(
      {out <- dwca_read(file, read = TRUE)}, 
      error=function(x) {"Link does not resolve to a public IPT resource"}
    )
    
    if (exists("out")){ 
      

      if (is.null(out$data[["event.txt"]]) == FALSE){
        Event <-out$data[["event.txt"]] 
        Event <- cleandataframe(Event) }
      
      if (is.null(out$data[["occurrence.txt"]]) == FALSE){
        Occurrence <-out$data[["occurrence.txt"]] 
        Occurrence <- cleandataframe(Occurrence) }
      
      if (is.null(out$data[["extendedmeasurementorfact.txt"]]) == FALSE){
        eMoF <-out$data[["extendedmeasurementorfact.txt"]]  
        eMoF <- cleandataframe(eMoF) }
      
      if(exists("eMoF") == FALSE & is.null(out$data[["measurementorfact.txt"]]) == FALSE) { 
        eMoF <- out$data[["measurementorfact.txt"]] 
        eMoF <- cleandataframe(eMoF) }

    }
      
  }
    if (exists("Event")){
    if (exists("events")) {
      events <- bind_rows(events, Event) 
    } else {   events <-Event }
      rm(Event)
    }
    
    if (exists("Occurrence")){
    if (exists("occurrences")) {
      occurrences <- bind_rows(occurrences, Occurrence) 
    } else {   occurrences <-Occurrence }
      rm(Occurrence )
    }
      
    if (exists("eMoF")){
    if (exists("emofs")) {
      emofs <- bind_rows(emofs, eMoF) 
    } else {   emofs <-eMoF }
      rm(eMoF )
    }
    
  }
    
if (is.data.frame(eurobisdata) == FALSE) {
export <- list()
if (exists("events")) {export$Event <- events}
if (exists("occurrences")) {export$Occurrence <- occurrences}
if (exists("emofs")) {export$eMoF <- emofs } 

} else {
export <- list()
  
eurobisdata <- eurobisdata %>% fncols (c(eventhierarchy, "occurrenceID")) %>% 
    select (eventhierarchy, occurrenceid)

#for (i in eventhierarchy) {
# if (exists("eventids")) {
#   eventids <- c(eventids, eurobisdata$eventhierarchy) } else {
#   eventids <- eurobisdata$eventhierarchy  }
#}
  if (exists("events")) {
    s1 <- events %>% filter (eventID %in% eventids)
    s2 <- events %>% filter (eventID %in% (s1 %>% fncols("parentEventID"))$parentEventID)
    s3 <- events %>% filter (eventID %in% (s2 %>% fncols("parentEventID"))$parentEventID)
    
  export$Event<-  bind_rows(s1,s2,s3)
  }
  
  if (exists("occurrences")) {
    export$Occurrence <- occurrences %>% filter (occurrenceID %in% eurobisdata$occurrenceid)
  }
  
  if (exists("emofs")) {
 #    e1 <- emofs %>% filter (occurrenceID %in% eurobisdata$occurrenceID)
 #   e2 <- emofs %>% filter (is.na(occurrenceID) & id eurobisdata$occurrenceID)
 #    export$eMoF
  }
  
  
   
}
return(export)}
}