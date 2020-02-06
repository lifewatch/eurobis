
eurobis
========

[![funding](https://img.shields.io/static/v1?label=powered+by&message=lifewatch.be&link=http://lifewatch.be&color=blue)](https://www.lifewatch.be)

[![EurOBIS](https://www.eurobis.org/images/web_resolution_logo_Eurobis.png)](https://www.eurobis.org/)

An R package to get downloads from the EurOBIS database. 

This package builds further on EurOBIS/EMODnet Biology WFS services. The functions allows you to download data using AphiaID, IMIS DasID or a geoserver URL you obtain through the EMODnet Biology toolbox http://www.emodnet-biology.eu/toolbox

## Installation

Installing `eurobis` requires the `devtools` and 'imis' packages:

```R
install.packages("devtools")
devtools::install_github("EMODnet/imis")
devtools::install_github("lifewatch/eurobis")
library("eurobis")
```

## Usage:

- `getemodbiodata(dasid = "4662")`   - download data from a single dataset. Use the dasid obtained through the http://www.emodnet-biology.eu/data-catalog (the id from the url) or use the function `listemodnetdatasets()` to get an overview

- `getemodbiodata(aphiaid = "141433")` - download data from a single taxon (the child taxa will be included also). Use the AphiaID obtained through http://www.marinespecies.org

- `getemodbiodata(dasid = "1884", type ="basic")` - download data only for 8 essential columns (see http://www.emodnet-biology.eu/node/172#Basic) 

- `getemodbiodata(mrgid=c("5670","3315"))` - download data from a specific region using the MRGID from marineregions, or type `View(IHOareas)`, `View(EEZs)`, `View(FAOareas)` to get an overview.

- `getemodbiodata(speciesgroup = "Angiosperms")` - download data from a functional group. Values are "Algae" , "Angiosperms", "Benthos", "Birds", "Fish", "Mammals", "phytoplankton", Reptiles", "zooplankton" (case sensitive - note phytoplankton and zooplankton are lower case)

- `getemodbiodata(dasid = c("1884","618", "5780" ), aphiaid = "2036", startyear = "1980", endyear = "2010")`

- `getemodbiodata(geourl = "http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv&resultType=results&viewParams=where%3Adatasetid+IN+%285885%29%3Bcontext%3A0100&outputFormat=csv")` download data using the WFS urls optained through the EMODnet toolbox at http://www.emodnet-biology.eu/toolbox/en/download/occurrence/preview (- you make your selection and copi-paste the url behind the "get webservice url" button)

## Output:

List with 3 data frames
- data - downloaded records
- meta - the descriptions of the terms
- datasets - the titles, citations and licences of the datasets used in the download




## Disclaimer

If data are extracted from the EMODnet Biology for secondary analysis resulting in a publication, the appropriate source should be cited.

The downloaded data should be cited as: EMODnet Biology (yyyy) Fulll Occurrence Data and parameters downloaded from the EMODnet Biology Project (www.emodnet-biology.eu). Available online at www.emodnet-biology.eu/toolbox, consulted on yyyy-mm-dd.

Regarding the citation of the individual datasets, the following guidelines should be taken into account:

- If any individual data source of EurOBIS constitutes a significant proportion of the downloaded and used records (e.g. more than 10% of the data is derived from a single source), the individual data source should also be cited.
- If any individual data source of EurOBIS constitutes a substantial proportion of the downloaded and used records (e.g. more than 25% of the data is derived from a single source or the data is essential to arrive at the conclusion of the analysis), the manager or custodian of this data set should be contacted.
- In any case, it may be useful to contact the data custodian directly. The data custodian might have additional data available that may strengthen the analysis or he/she might be able to provide additional helpful information that may not be apparent from the provided metadata.
- The data may not be redistributed without the permission of the appropriate data owners. If data are extracted from the EMODnet Data Portal for redistribution, please contact us at bio@emodnet.eu.

[![LifeWatch.be](https://raw.githubusercontent.com/EMODnet/REMODBio/master/fig/LifeWatch_banner_test.PNG)](http://www.lifewatch.be/)
