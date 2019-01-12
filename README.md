# REMODBio


An R function to get from the EMODnet Biology WFS. This function allows you to download data using aphiaID, dasid or using an geoserverURL you get from the EMODnet Biology toolbox


## Installation

Installing `REMODBio` requires the `devtools` and 'imis' packages:

```R
install.packages("devtools")
devtools::install_github("Daphnisd/REMODBio")
devtools::install_github("iobis/imis")
library("REMODBio")


## Usage:

- downloaddata <- getemodbiodata(dasid = "4662")   - download data from a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url)

- downloaddata <- getemodbiodata(aphiaid = "141433") - download data from a single taxon. uses the id obtained through ww.marinespecies.org

- downloaddata <- getemodbiodata(dasid = c("1884","618", "5780" ), aphiaid = "2036", startyear = "1980", endyear = "2010")

- downloaddata <- getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&outputFormat=csv") download data using the WFS urls optained through the EMODnet toolbox at http://www.emodnet-biology.eu/toolbox/en/download/occurrence/explore (use the full download with parameters option)
