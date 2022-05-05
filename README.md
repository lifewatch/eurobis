
eurobis
========
[![Funding](https://img.shields.io/static/v1?label=powered+by&message=lifewatch.be&labelColor=1a4e8a&color=f15922)](http://lifewatch.be)


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

## Get occurrences

Use the `eurobis_occurrences()` function. You can filter on dataset, time, taxon name and AphiaID WoRMS identifier, functional group and some important classifications such as the IUCN Red List or MSDF Indicators.

Via the first argument `type` you must select the level of detail you desire to download: `basic`, `full` or `full_and_parameters`:

```r
occ <- eurobis_occurrences("basic", dasid = 8045)
```

```r
occ2 <- eurobis_occurrences("basic", dasid = 8045, scientificname = "Zostera marina")
```

```r
occ3 <- eurobis_occurrences("full", dasid = 8045, functional_groups = "angiosperms")
```

```r
occ4 <- eurobis_occurrences("full_and_parameters", dasid = 8045, iucn_red_list = "least concern")
```


## Query by location

You can also filter by location, either using the Marine Regions Gazetteer Identifier (MRGID) or passing any polygon as Well Known Text.

To help drawing the area of your interest, you can use `eurobis_map_draw()`. You can draw here a polygon interactively:

```r
selected_area <- eurobis_map_draw()
selected_area
#> POLYGON ((-9.625301 38.19684, -9.625301 39.7145, -8.61519 39.7145, -8.61519 38.19684, -9.625301 38.19684))
occ5 <- eurobis_occurrences("basic", geometry = selected_area)
```

To help choosing the MRGID from Marine Regions, the function `eurobis_map_mr()`

```r
eurobis_map_mr('eez')
```

For instance, you can click on the Portuguese Exclusive Economic Zone and you will see that the MRGID is 5688. 

```r
occ6 <- eurobis_occurrences("basic", mrgid = 5688, geometry = selected_area)
```
Note that passing both an MRGID and a geometry does not restrict to the selected area within the MRGID record, but adds both data fetched from the selected data and the MRGID record.

You can pass the different Marine Regions data products in which you can filter: one of `eez`, `iho` and `eez_iho`.


## Disclaimer

If data are extracted from the EMODnet Biology for secondary analysis resulting in a publication, the appropriate source should be cited.

The downloaded data should be cited as: EMODnet Biology (yyyy) Fulll Occurrence Data and parameters downloaded from the EMODnet Biology Project (www.emodnet-biology.eu). Available online at www.emodnet-biology.eu/toolbox, consulted on yyyy-mm-dd.

Regarding the citation of the individual datasets, the following guidelines should be taken into account:

- If any individual data source of EurOBIS constitutes a significant proportion of the downloaded and used records (e.g. more than 10% of the data is derived from a single source), the individual data source should also be cited.
- If any individual data source of EurOBIS constitutes a substantial proportion of the downloaded and used records (e.g. more than 25% of the data is derived from a single source or the data is essential to arrive at the conclusion of the analysis), the manager or custodian of this data set should be contacted.
- In any case, it may be useful to contact the data custodian directly. The data custodian might have additional data available that may strengthen the analysis or he/she might be able to provide additional helpful information that may not be apparent from the provided metadata.
- The data may not be redistributed without the permission of the appropriate data owners. If data are extracted from the EMODnet Data Portal for redistribution, please contact us at bio@emodnet.eu.

[![LifeWatch.be](https://raw.githubusercontent.com/lifewatch/eurobis/master/fig/LifeWatch_banner_test.PNG)](http://www.lifewatch.be/)
