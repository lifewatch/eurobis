#' Get citations and licence from IMIS based on dasids
#'
#' This function gets the citations and DOIs from IMIS using the dasids 
#' @param dasid mandatory parameter, the dasid of the dataset
#' @import imis dplyr 
#' @export
#' @examples
#' meta <- getcitations(4662)
#' meta <- getcitations(dasid = c("1884","618", "5780" ))


getcitations <- function (dasid) {
  dasid <- unique(dasid[!is.na(dasid)])
  dasid <- dasid[(dasid != "")]
  
datasetrecords <- datasets(dasid)
  
for (i in 1:length(datasetrecords)){
  for (j in 1:length(datasetrecords[[i]]$urls)){
    for (k in 1:length(datasetrecords[[i]]$dois)){
      
      l <- lapply(datasetrecords, function(term) {
        element <- rlang::as_list(term)
        return(list(
          dasid = unlist(datasetrecords[[i]]$datasetrec$DasID),
          title = unlist(datasetrecords[[i]]$datasetrec$StandardTitle),
          url = unlist(datasetrecords[[i]]$urls[[j]]$URL), 
          urltype = unlist(datasetrecords[[i]]$urls[[j]]$URLType),
          DOI = unlist(datasetrecords[[i]]$dois[[k]]$DOIID),
          doicitation = unlist(datasetrecords[[i]]$dois[[k]]$Citation),
          imiscitation = unlist(datasetrecords[[i]]$datasetrec$Citation),
          licence = unlist(datasetrecords[[i]]$datasetrec$AccConstrEN),
          accessconstraint = unlist(datasetrecords[[i]]$datasetrec$AccessConstraints),
          abstract = unlist(datasetrecords[[i]]$datasetrec$EngAbstract),
          description = unlist(datasetrecords[[i]]$datasetrec$EngDescr)
        ))})
    }
    r1 <-bind_rows(unlist(l))
    if (exists("r2")){
      r2 <- bind_rows(r2, r1)
    } else { 
      r2<-r1
    }}
  if (exists("returndatasets")){
    returndatasets <- bind_rows(returndatasets, r2)
  } else { 
    returndatasets<-r2} }

returndatasets <- returndatasets %>% fncols(c("dasid","title","url","urltype","DOI","doicitation","imiscitation","licence","accessconstraint","abstract", "description"))

c1 <- returndatasets %>% select (dasid, title, licence,imiscitation,accessconstraint,abstract, description) %>% distinct()
c2 <- returndatasets %>% filter (urltype == "DOI" ) %>% select (dasid, url) %>% distinct()
c3 <- returndatasets %>% filter (!is.na(DOI)) %>% group_by(dasid) %>% summarise (selectdoi = max(DOI)) %>% ungroup()
c4 <- returndatasets %>% select (dasid, DOI, doicitation) %>% filter (DOI %in% c3$selectdoi) %>% distinct_()

datasets <- c1  %>% left_join(c2, by="dasid") %>% left_join(c4, by="dasid") %>% 
  mutate(citation = if_else(!is.na(doicitation),paste0(doicitation, " https://doi.org/10.14284/",DOI),
                            if_else(!is.na(url), paste0(imiscitation, " ",url), imiscitation)),
         DOI = if_else(!is.na(DOI),paste0(" https://doi.org/10.14284/",DOI),
                        if_else(!is.na(url), url, ""))) %>%
  select (dasid, title, citation, DOI, licence, accessconstraint,abstract, description)

return(datasets)
}