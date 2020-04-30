#' Get data from the EurOBIS through the EMODnet Biology WFS
#'
#' This function allows you to download data using aphiaID, dasid or using an geoserverURL you get from the EMODnet Biology toolbox
#' @param geourl optional parameter, in case you use the geoserverURL obtained through the EMODnet Biology toolbox http://www.emodnet-biology.eu/toolbox/en/download/occurrence/explore
#' @param dasid optional parameter, in case you want to download a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url)
#' @param aphiaid optional parameter, in case you want to download data from a single taxon. Uses the id obtained throug ww.marinespecies.org
#' @param speciesgroup optional parameter, in case you want to download data for a functional group. Values are "Algae" , "Angiosperms", "Benthos", "Birds", "Fish", "Mammals", "phytoplankton", Reptiles", "zooplankton" (Case sensitive)
#' @param mrgid optional parameter, in case you want to download data for a specific region. Use mrgid from marineregions.org or type View(IHOareas) to get an overview of the available IHO areas.
#' @param startyear optional parameter, the earliest year the collected specimen might have been collected
#' @param endyear optional parameter, the latest year the collected specimen might have been collected
#' @param type indicates if you want a basic download "basic" (only date, coordinates and taxon) or you want all data "full" returned from the WFS
#' @import dplyr imis reshape2
#' @export
#' @examples
#' getEurobisData(dasid = "4662")
#' getEurobisData(aphiaid = "141433")
#' getEurobisData(speciesgroup = "Angiosperms")
#' getEurobisData(dasid = c("1884","618", "5780" ), aphiaid = "2036")
#' getEurobisData(dasid = "1884", type ="basic")
#' getEurobisData(mrgid=c("5670","3315"))
#' getEurobisData(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&outputFormat=csv")



getEurobisData <- function(geourl = NA, dasid = NA, aphiaid = NA, mrgid = NA, speciesgroup = NA, startyear = "1850", endyear = NA, type ="full"){
  

wfsurls <-  createwfsurls(geourl, dasid, aphiaid, mrgid, startyear, endyear, type)

if (any(wfsurls != "please provide geourl dasid or aphiaid")){

    for  (j in 1:length(wfsurls)) {
      print(paste0("downloading records ", trimws(format(((j-1)*20000)+1,digits=9)) , "-", trimws(format((j*20000), digits=9))))
      
      eurobisdata <- tryCatch({eurobisdata <- read.csv(wfsurls[j])}, error = function(e) { 
        message("error read.csv: ", e)
        message("trying download.file: ")
        file <-  paste0("emodnetbiodata",Sys.Date(),".csv")
        options(timeout=10000)
        download.file(wfsurls[j], file, method="internal", cacheOK = FALSE)
        eurobisdata <-read.csv(file, stringsAsFactors = FALSE)
        file.remove(file)
        rm(file)
        return(eurobisdata)
      })
      
      if ( nrow(eurobisdata) > 0 & length(eurobisdata) > 2 ){
      
        eurobisdata <- data.frame(lapply(eurobisdata, as.character), stringsAsFactors=FALSE)
        
        if (exists("comeurobisdata")){
          comeurobisdata <- bind_rows(comeurobisdata, eurobisdata)
          rm(eurobisdata)
        } else { 
          comeurobisdata <-  eurobisdata  
          rm(eurobisdata)}
       
      } else {
        print("no more records found")
        break
        }
    }
  
  
    
if (exists("comeurobisdata") == FALSE) {print("no data in selection")} else {
  if (type == "full"){
    fulloccurrence <- comeurobisdata %>% select (FID:samplingprotocol, qc) %>% distinct()
    
    toflattenpara <- comeurobisdata %>% select (1, parameter, parameter_value) %>% distinct()
    toflattenev <- comeurobisdata %>% select (1, event, event_type) %>% filter (!is.na(event_type) & event_type != "") %>% distinct()
    
    parameters <- toflattenpara %>% data.table::dcast(FID ~ parameter, value.var=c("parameter_value"))
    if (nrow(toflattenev)>0){
      suppressWarnings(events <- toflattenev %>% data.table::dcast(FID ~ event_type, value.var=c("event")) %>% select(FID, one_of(c("cruise","stationVisit", "sample", "subsample"))))
    } else {events <- toflattenev %>% select (FID)}
    occurrenceflat <-  events %>% full_join(fulloccurrence, by ="FID") %>% full_join(parameters, by ="FID")
    
    
    occurrenceflat[occurrenceflat =='NA' | occurrenceflat =='' | occurrenceflat ==' '] <- NA
    occurrenceflat <- occurrenceflat[,colSums(is.na(occurrenceflat))<nrow(occurrenceflat)]
    
    parainclude <- names(occurrenceflat)
   
    paradescriptions <-  comeurobisdata %>% select (datasetid, parameter, parameter_measurementtypeid:parameter_conversion_factor_to_standard_unit) %>% filter (!is.na(parameter) & parameter != "") %>% distinct()
    
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
      occurrenceflat  <- comeurobisdata 
      paradescriptions <- basicdata %>%  mutate (parameterPreferredLabel = Term) %>% select( parameterName = Term, parameterID = DarwinCore.URI, 
                                                parameterPreferredLabel, parameterDefinition = Definition)
    }
  meta <- occurrenceflat %>% group_by(datasetid) %>% summarise(numberofrecords = n()) %>% mutate(proportionofdataset = numberofrecords/ sum(numberofrecords))%>% ungroup() %>%
      mutate(dasid =  richtfrom(datasetid, 'dasid=', 5))
    
    
    print("getting EMODnet catolog metadata")
    datasets<-getdascitations(datasets(meta$dasid))
    
    datasets <- datasets %>% left_join(meta, by ="dasid") %>%
        select (dasid, numberofrecords, proportionofdataset, title, citation, licence, accessconstraint) %>% arrange(desc(proportionofdataset)) %>%
        mutate(dasid = paste0("http://www.emodnet-biology.eu/data-catalog?dasid=",dasid))
    
    
    out<-list()      
    out$meta <- paradescriptions 
    out$data <- occurrenceflat
    out$datasets <- datasets
    
    
    return(out)

}}}

