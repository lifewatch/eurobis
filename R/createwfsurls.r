#' Helpfunction to create the wfsurl
#'
#' @export


createwfsurls <- function (geourl = NA, dasid = NA, aphiaid = NA, startyear = NA, endyear = NA, type="full") {
  
  
  if (type == "full") {
    geolayer = "eurobis-obisenv"
  } else if (type == "basic") {
    geolayer = "eurobis-obisenv_basic"
  }
  
  offset <-seq(from = 0, to =  100000000, by = 20000)
  
  if(any(is.na(geourl)) & any(is.na(dasid)) & any(is.na(aphiaid))) {print("please provide geourl dasid or aphiaid")
  } else {
    # http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal:eurobis-obisenv&resultType=results&viewParams= order: ORDER BY obs.id LIMIT 20000 OFFSET 0 ;where:datasetid IN (5885);context:0100&outputFormat=csv
      wfsprefix <-paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal%3A",geolayer,"&viewParams=%20order:%20ORDER%20BY%20obs.id%20LIMIT%20", offset[2] ,"%20OFFSET%20", trimws(format(offset,digits=9)) ,"%20;where:")
    if(!is.na(geourl)) {
      if (any(grepl("propertyName", geourl))) {
      wfssuffix <- paste0("+AND+",sectioninstring (geourl, starchar="Params=where", n=-15, endchar = "propertyName=", m=2 ),"&outputformat=csv")} else {
      wfssuffix <- paste0("+AND+",richtfrom(geourl, 'Params=where',14)) 
      }   } else {
      wfssuffix <-"&outputformat=csv"
    }
    
    if (any(!is.na(dasid)))  { datasetpart <- paste0('datasetid+IN+%28', 
                             paste0(dasid, collapse="%5C%2C"), '%29')  } 
    
    if (any(!is.na(aphiaid))) { 
      
            aphiapart1 <- paste0('aphiaid+IN+%28', 
                                  paste0(aphiaid, collapse="%5C%2C"), '%29')
            aphiapart2 <- paste0('aphiaidaccepted+IN+%28', 
                                 paste0(aphiaid, collapse="%5C%2C"), '%29')
      
      aphiapart <- paste0("(",aphiapart1, "+OR+",aphiapart2, ")")
            } 
                                                  
     
    if (!is.na(endyear) & is.na(startyear)) { startyear = 1850}
    if (is.na(endyear)& !is.na(startyear)) { endyear = format(Sys.Date(), "%Y")}
    
      if (!is.na(startyear) & !is.na(endyear)) {
      yearcollectedpart <- paste0("%28%28yearcollected+BETWEEN+%27+",startyear, "%27+AND+%27" , endyear,"%27%29%29") } 
      
      
      middlepart <- paste0(
        if (exists("datasetpart")) {datasetpart} ,
        if (exists("datasetpart") & exists("aphiapart")) {paste0("+AND+", aphiapart)} else {
           if ( !exists("datasetpart") & exists("aphiapart")) {aphiapart}} , 
        if ( exists("aphiapart") & exists("yearcollectedpart")) {paste0("+AND+",yearcollectedpart)} else {
          if (!exists("datasetpart") & !exists("aphiapart") & exists("yearcollectedpart")) {yearcollectedpart}}
      )


      wfsurl <-  paste0(wfsprefix, middlepart, wfssuffix)

      }
      return(wfsurl)  

    }
  