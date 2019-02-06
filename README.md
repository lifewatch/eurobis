# REMODBio


An R function to get data from the EMODnet Biology WFS. This function allows you to download data using aphiaID, dasID or an geoserverURL you get from the EMODnet Biology toolbox http://www.emodnet-biology.eu/toolbox


## Installation

Installing `REMODBio` requires the `devtools` and 'imis' packages:

```R
install.packages("devtools")
devtools::install_github("EMODnet/imis")
devtools::install_github("Daphnisd/REMODBio")
library("REMODBio")
```

## Usage:

- `getemodbiodata(dasid = "4662")`   - download data from a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url)

- `getemodbiodata(aphiaid = "141433")` - download data from a single taxon. Use the id obtained through www.marinespecies.org

- `getemodbiodata(dasid = "1884", type ="basic")` - download data only for 8 essential collumns (see http://www.emodnet-biology.eu/node/172#Basic) 

- `getemodbiodata(dasid = c("1884","618", "5780" ), aphiaid = "2036", startyear = "1980", endyear = "2010")`

- `getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&outputFormat=csv")` download data using the WFS urls optained through the EMODnet toolbox at http://www.emodnet-biology.eu/toolbox/en/download/occurrence/explore (- you make your selection and copi-paste the url behind the "get webservice url" button)

## Output:

List with 3 data frames
- data - downloaded records
- meta - the descriptions of the terms
- datasets - the titles, citations and licences of the datasets used in the download
