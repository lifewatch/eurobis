
#' Get data from the EMODnet Biology WFS
#'
#' This function allows you to download data using aphiaID, dasid or using an geoserverURL you get from the EMODnet Biology toolbox
#' @param geourl optional parameter, in case you use the geoserverURL obtained through the EMODnet Biology toolbox http://www.emodnet-biology.eu/toolbox/en/download/occurrence/explore
#' @param dasid optional parameter, in case you want to dowload a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url)
#' @param aphiaid optional parameter, in case you want to dowload data from a single taxon. uses the id obtained throug ww.marinespecies.org
#' @keywords 
#' @export
#' @examples
#' getemodbiodata(dasid = "4662")
#' getemodbiodata(aphiaid = "141433")
#' getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cmodified%2Cinstitutioncode%2Ccollectioncode%2Cyearcollected%2Cstartyearcollected%2Cendyearcollected%2Cmonthcollected%2Cstartmonthcollected%2Cendmonthcollected%2Cdaycollected%2Cstartdaycollected%2Cenddaycollected%2Cseasoncollected%2Ctimeofday%2Cstarttimeofday%2Cendtimeofday%2Ctimezone%2Cwaterbody%2Ccountry%2Cstateprovince%2Ccounty%2Crecordnumber%2Cfieldnumber%2Cstartdecimallongitude%2Cenddecimallongitude%2Cstartdecimallatitude%2Cenddecimallatitude%2Cgeoreferenceprotocol%2Cminimumdepthinmeters%2Cmaximumdepthinmeters%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ctaxonrank%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Cinfraspecificepithet%2Caphiaidaccepted%2Coccurrenceremarks%2Cbasisofrecord%2Ctypestatus%2Ccatalognumber%2Creferences%2Crecordedby%2Cidentifiedby%2Cyearidentified%2Cmonthidentified%2Cdayidentified%2Cpreparations%2Csamplingeffort%2Csamplingprotocol%2Cqc%2Ceventid%2Cparameter%2Cparameter_value%2Cparameter_group_id%2Cparameter_measurementtypeid%2Cparameter_bodcterm%2Cparameter_bodcterm_definition%2Cparameter_standardunit%2Cparameter_standardunitid%2Cparameter_imisdasid%2Cparameter_ipturl%2Cparameter_original_measurement_type%2Cparameter_original_measurement_unit%2Cparameter_conversion_factor_to_standard_unit%2Cevent%2Cevent_type%2Cevent_type_id&outputFormat=csv")



getemodbiodata <- function(geourl = "NO", dasid = "NO", aphiaid = "NO"){

    if (geourl != "NO") {
    emodnetbiodata <- geourl
    } else  if (aphiaid != "NO") {
      emodnetbiodata <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&viewParams=where:aphiaidaccepted=",aphiaid,"&outputformat=csv")
    } else  if (dasid != "NO") {
    emodnetbiodata <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&viewParams=where:datasetid=",dasid,"&outputformat=csv")
  } else {print ("please provide valid input")}
  
  
  require("dplyr")
  require("data.table")
  
  downloaddata <- list()
  
  ### download and read data  
  file <-  paste0("emodnetbiodata",Sys.Date(),".csv")
  options(timeout=10000)
  download.file(emodnetbiodata, file, method="internal", cacheOK = FALSE)
  emoddata <-read.csv(file, stringsAsFactors = FALSE)
  file.remove(file)  
  rm(file) 
  

  emoddata <- data.frame(lapply(emoddata, as.character), stringsAsFactors=FALSE)
  
  
  fulloccurrence <- emoddata[1:68] %>% distinct()
  fulloccurrence[fulloccurrence =='NA' | fulloccurrence =='' | fulloccurrence ==' '] <- NA
  fulloccurrence <- fulloccurrence[,colSums(is.na(fulloccurrence))<nrow(fulloccurrence)]
  
  
  toflattenpara <- emoddata %>% select (1, parameter, parameter_value) %>% distinct()
  toflattenev <- emoddata %>% select (1, event, event_type) %>% filter (!is.na(event_type) & event_type != "") %>% distinct()
  
  
  parameters <- toflattenpara %>% dcast(FID ~ parameter, value.var=c("parameter_value"))
  if (nrow(toflattenev)>0){
  events <- toflattenev %>% dcast(FID ~ event_type, value.var=c("event")) %>% select(FID, one_of(c("cruise","stationVisit", "sample", "subsample")))
  } else {events <- toflattenev %>% select (FID)}
  downloaddata$occurrenceflat <-  events %>% full_join(fulloccurrence, by ="FID") %>% full_join(parameters, by ="FID")
  
  
  
  return(downloaddata)
  
}