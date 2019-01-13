#' Helpfunction to create the wfsul
#'
#' @export


createwfsurls <- function (geourl = NA, dasid = NA, aphiaid = NA, startyear = NA, endyear = NA, type="full") {
  
  
  if (type == "full") {
    geolayer = "eurobis-obisenv"
  } else if (type == "basic") {
    geolayer = "eurobis-obisenv_basic"
  }
  
  if(any(is.na(geourl)) & any(is.na(dasid)) & any(is.na(aphiaid))) {print("please provide geourl dasid or aphiaid")
  } else {
  
      wfsprefix <-paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal%3A",geolayer,"&viewParams=where:")
    if(!is.na(geourl)) {
      wfssuffix <- paste0("+AND+",richtfrom(geourl, 'Params=where',3))
    } else {
      wfssuffix <-"&outputformat=csv"
    }
    
    if (any(!is.na(dasid)))  { datasetpart <- paste0("datasetid=", dasid, "+AND+")  
    } else {datasetpart <-"" }
    
    if (any(!is.na(aphiaid))) { aphiapart <- paste0("(aphiaid=",aphiaid,"+OR+aphiaidaccepted=",aphiaid,")+AND+")
    } else {aphiapart <-"" } 
    
    if (!is.na(startyear) & is.na(endyear)) {endyear = format(Sys.Date(), "%Y")}
    if (is.na(startyear) & !is.na(endyear)) {startyear = "1850" }
    
    if (is.na(startyear)) {
      wfsurls <- paste0(wfsprefix, datasetpart, aphiapart, "yearcollected=NULL", wfssuffix)
      
      for (i in 1850:format(Sys.Date(), "%Y")){
        yearcollectedpart <- paste0("yearcollected=",i)
        wfsurl <-  paste0(wfsprefix, datasetpart, aphiapart, yearcollectedpart, wfssuffix)
        wfsurls <-  c(wfsurls,wfsurl)
      }
    }
    
    if (!is.na(startyear)) {
      
      for (i in startyear:endyear){
        yearcollectedpart <- paste0("yearcollected=",i)
        
        wfsurl <-  paste0(wfsprefix, datasetpart, aphiapart, yearcollectedpart, wfssuffix)
        if (exists("wfsurls")) {
          wfsurls <-  c(wfsurls,wfsurl) } else { 
            wfsurls <-wfsurl   }
      }
    }
      return(wfsurls)  
      
  }
}