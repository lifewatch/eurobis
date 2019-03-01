#' Helpfunction to create the wfsurl
#'
#' @export


createwfsurls <- function (geourl = NA, dasid = NA, aphiaid = NA, mrgid = NA,  startyear = NA, endyear = NA, type="full") {
  
  
  if (type == "full") {
    geolayer = "eurobis-obisenv"
  } else if (type == "basic") {
    geolayer = "eurobis-obisenv_basic"
  }
  
  offset <-seq(from = 0, to =  100000000, by = 20000)
  
  if(any(is.na(geourl)) & any(is.na(dasid)) & any(is.na(aphiaid)) &  any(is.na(mrgid))) {print("please provide geourl dasid or aphiaid")
  } else {
    # http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal:eurobis-obisenv&resultType=results&viewParams= order: ORDER BY obs.id LIMIT 20000 OFFSET 0 ;where:datasetid IN (5885);context:0100&outputFormat=csv
      wfsprefix <-paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=Dataportal%3A",geolayer,"&viewParams=%20order:%20ORDER%20BY%20obs.id%20LIMIT%20", offset[2] ,"%20OFFSET%20", trimws(format(offset,digits=9)) ,"%20;")
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
            aphiapart <- paste0('aphiaid:', 
                             paste0(aphiaid, collapse="%5C%2C", ";"))
      
  
            } 
       
      if (any(!is.na(mrgid))) { 
        
        mrgpart <- paste0('%28%28up.geoobjectsids+%26%26+ARRAY%5B', 
                             paste0(mrgid, collapse="%5C%2C"), '%5D%29%29')

      }                                           
      
  
    if (!is.na(endyear) & is.na(startyear)) { startyear = 1850}
    if (is.na(endyear)& !is.na(startyear)) { endyear = format(Sys.Date(), "%Y")}
    
      if (!is.na(startyear) & !is.na(endyear)) {
      yearcollectedpart <- paste0("%28%28yearcollected+BETWEEN+%27+",startyear, "%27+AND+%27" , endyear,"%27%29%29") } 
      
      parts<- c(if(exists("datasetpart"))datasetpart ,
                if(exists("mrgpart"))mrgpart,if(exists("yearcollectedpart"))yearcollectedpart )
    

      if(!is.null(parts)){
      middlepart <- paste0(parts, collapse="+AND+")}
      
        
      
      wfsurl <-  paste0(wfsprefix, if(exists("aphiapart"))aphiapart,if(!is.null(parts)) 'where:', if(exists("middlepart"))middlepart, wfssuffix)

      }
      return(wfsurl)  

    }
  
