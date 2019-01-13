#' Get data from the EMODnet Biology WFS
#'
#' This function allows you to download data using aphiaID, dasid or using an geoserverURL you get from the EMODnet Biology toolbox
#' @param geourl optional parameter, in case you use the geoserverURL obtained through the EMODnet Biology toolbox http://www.emodnet-biology.eu/toolbox/en/download/occurrence/explore
#' @param dasid optional parameter, in case you want to download a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url)
#' @param aphiaid optional parameter, in case you want to download data from a single taxon. uses the id obtained throug ww.marinespecies.org
#' @param startyear optional parameter, the earliest year the collected specimen might have been collected
#' @param endyear optional parameter, the latest year the collected specimen might have been collected
#' @param type indicates if you want a basic download "basic" (only date, coordinates and taxon) or you want all data "full" returned from the WFS
#' @import dplyr 
#' @export
#' @examples
#' downloaddata <- getemodbiodata(dasid = "4662")
#' downloaddata <- getemodbiodata(aphiaid = "141433")
#' downloaddata <- getemodbiodata(dasid = c("1884","618", "5780" ), aphiaid = "2036")
#' getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2Cscientificnameaccepted%2Cmodified%2Cinstitutioncode%2Ccollectioncode%2Cyearcollected%2Cstartyearcollected%2Cendyearcollected%2Cmonthcollected%2Cstartmonthcollected%2Cendmonthcollected%2Cdaycollected%2Cstartdaycollected%2Cenddaycollected%2Cseasoncollected%2Ctimeofday%2Cstarttimeofday%2Cendtimeofday%2Ctimezone%2Cwaterbody%2Ccountry%2Cstateprovince%2Ccounty%2Crecordnumber%2Cfieldnumber%2Cstartdecimallongitude%2Cenddecimallongitude%2Cstartdecimallatitude%2Cenddecimallatitude%2Cgeoreferenceprotocol%2Cminimumdepthinmeters%2Cmaximumdepthinmeters%2Coccurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ctaxonrank%2Ckingdom%2Cphylum%2Cclass%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Cspecificepithet%2Cinfraspecificepithet%2Caphiaidaccepted%2Coccurrenceremarks%2Cbasisofrecord%2Ctypestatus%2Ccatalognumber%2Creferences%2Crecordedby%2Cidentifiedby%2Cyearidentified%2Cmonthidentified%2Cdayidentified%2Cpreparations%2Csamplingeffort%2Csamplingprotocol%2Cqc%2Ceventid%2Cparameter%2Cparameter_value%2Cparameter_group_id%2Cparameter_measurementtypeid%2Cparameter_bodcterm%2Cparameter_bodcterm_definition%2Cparameter_standardunit%2Cparameter_standardunitid%2Cparameter_imisdasid%2Cparameter_ipturl%2Cparameter_original_measurement_type%2Cparameter_original_measurement_unit%2Cparameter_conversion_factor_to_standard_unit%2Cevent%2Cevent_type%2Cevent_type_id&outputFormat=csv")




getemodbiodata <- function(geourl = NA, dasid = NA, aphiaid = NA, startyear = NA, endyear = NA, type ="full"){
  

wfsurls <-  createwfsurls(geourl, dasid, aphiaid, startyear, endyear, type)

if (any(wfsurls != "please provide geourl dasid or aphiaid")){

    for (j in wfsurls) {
      print(j)
      
      tryCatch({emoddata <- read.csv(j)}, error = function(e) { 
        file <-  paste0("emodnetbiodata",Sys.Date(),".csv")
        options(timeout=10000)
        download.file(j, file, method="internal", cacheOK = FALSE)
        emoddata <-read.csv(file, stringsAsFactors = FALSE)
        file.remove(file)  
        rm(file)
      })
      if ( nrow(emoddata) > 0 ){
        
        emoddata <- data.frame(lapply(emoddata, as.character), stringsAsFactors=FALSE)
        
        if (exists("comemoddata")){
          comemoddata <- bind_rows(comemoddata, emoddata)
        } else { 
          comemoddata<-emoddata
        }
        
      }
      
      rm(emoddata)
    }
    
if (type == "full"){
    fulloccurrence <- comemoddata %>% select (FID:samplingprotocol, qc) %>% distinct()
    
    toflattenpara <- comemoddata %>% select (1, parameter, parameter_value) %>% distinct()
    toflattenev <- comemoddata %>% select (1, event, event_type) %>% filter (!is.na(event_type) & event_type != "") %>% distinct()
    
    parameters <- toflattenpara %>% data.table::dcast(FID ~ parameter, value.var=c("parameter_value"))
    if (nrow(toflattenev)>0){
      suppressWarnings(events <- toflattenev %>% data.table::dcast(FID ~ event_type, value.var=c("event")) %>% select(FID, one_of(c("cruise","stationVisit", "sample", "subsample"))))
    } else {events <- toflattenev %>% select (FID)}
    occurrenceflat <-  events %>% full_join(fulloccurrence, by ="FID") %>% full_join(parameters, by ="FID")
    
    
    occurrenceflat[occurrenceflat =='NA' | occurrenceflat =='' | occurrenceflat ==' '] <- NA
    occurrenceflat <- occurrenceflat[,colSums(is.na(occurrenceflat))<nrow(occurrenceflat)]
    
    parainclude <- names(occurrenceflat)
   
    paradescriptions <-  comemoddata %>% select (datasetid, parameter, parameter_measurementtypeid:parameter_conversion_factor_to_standard_unit) %>% filter (!is.na(parameter)) %>% distinct()
    
    paradescriptions <- fulldata %>%  mutate (parameterPreferredLabel = Term) %>% select ( parameterName = Term, parameterID = DarwinCore.URI, 
                                              parameterPreferredLabel, parameterDefinition = Definition) %>% 
                                  filter (parameterName %in% parainclude) %>%
      bind_rows(paradescriptions %>% select (parameterName=parameter, parameterID=parameter_measurementtypeid, 
                                        parameterPreferredLabel=parameter_bodcterm,  parameterDefinition=parameter_bodcterm_definition,
                                        parameterUnit=parameter_standardunit, parameterUnitID=parameter_standardunitid,
                                        originalMeasurementType =parameter_original_measurement_type	,originalMeasurementUnit =parameter_original_measurement_unit,
                                        conversionFactor=parameter_conversion_factor_to_standard_unit, datasetID =datasetid ,
                                        datasetIPTurl =parameter_ipturl)) 
                

    
    rm(fulloccurrence,events,parameters,toflattenev,toflattenpara)
    } else if (type == "basic") {
      occurrenceflat  <- comemoddata 
      paradescriptions <- basicdata %>%  mutate (parameterPreferredLabel = Term) %>% select( parameterName = Term, parameterID = DarwinCore.URI, 
                                                parameterPreferredLabel, parameterDefinition = Definition)
    }
    
    meta <- occurrenceflat %>% group_by(datasetid) %>% summarise(numberofrecords = n()) %>%  mutate(proportionofdataset = numberofrecords/ sum(numberofrecords))%>% ungroup() %>%
      mutate(dasid =  richtfrom(datasetid, 'dasid=', 5))
    
    
    print("getting imis data")
    datasets<-getcitations(meta$dasid)
    
    datasets <- datasets %>% left_join(meta, by ="dasid") %>%
        select (dasid, numberofrecords, proportionofdataset, title, citation, licence, accessconstraint) %>% arrange(desc(proportionofdataset)) %>%
        mutate(dasid = paste0("http://www.emodnet-biology.eu/data-catalog?dasid=",dasid))
    
    
    out<-list()      
    out$meta <- paradescriptions 
    out$data <- occurrenceflat
    out$datasets <- datasets
    
    
    return(out)

}}

