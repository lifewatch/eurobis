# REMODBio


An R function to get from the EMODnet Biology WFS. This function allows you to download data using aphiaID, dasid or using an geoserverURL you get from the EMODnet Biology toolbox


## Installation

Installing `REMODBio` requires the `devtools` package:

```R
install.packages("devtools")
devtools::install_github("Daphnisd/REMODBio")
library("REMODBio")
```
## Download data:

`getemodbiodata(dasid = "4662")` download data for the dataset http://www.emodnet-biology.eu/data-catalog?dasid=4662. Get datasetid through http://www.emodnet-biology.eu/data-catalog

`getemodbiodata(aphiaid = "141433")` - download data for the taxon http://marinespecies.org/aphia.php?p=taxdetails&id=141433. Get aphiaids through http://marinespecies.org/aphia.php?p=search

`getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&outputFormat=csv")` downloads data using the WFS urls optained through the EMODnet toolbox at http://www.emodnet-biology.eu/toolbox/ (select the full download with parameters before requesting the webservice URL)
