
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Download data from EurOBIS using the LifeWatch/EMODnet-Biology Web Feature Services

<!-- badges: start -->

[![Funding](https://img.shields.io/static/v1?label=powered+by&message=lifewatch.be&labelColor=1a4e8a&color=f15922)](http://lifewatch.be)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The `eurobis` R package allows you to download data from EurOBIS.

You can query on:

  - **Dataset**: provide the Integrated Marine Information System
    ([IMIS](https://www.vliz.be/en/integrated-marine-information-system))
    unique identifier for datasets
    [DasID](https://www.vliz.be/imis?page=webservices).
  - **Taxon**: use a scientific name (e.g. the sea turtle *Caretta
    caretta*) or a [WoRMS
    AphiaID](https://www.marinespecies.org/about.php#what_is_aphia)
    (e.g. [137205](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137205))
  - **Traits**: get all occurrences that are benthos. Or zooplankton. Or
    both. Powered by [WoRMS](https://www.marinespecies.org/).
  - **Time**: just give start and end dates.
  - **Geographically**: it allows to query on more than 300 records from
    the [Marine Regions
    Gazetteer](https://marineregions.org/gazetteer.php) by giving the
    [MRGID](https://marineregions.org/mrgid.php). Or just pass the area
    of your interest as a polygon written in as [Well Known
    Text](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
  - Other important classifications as [IUCN Red
    List](https://www.iucnredlist.org/en), [MSDF
    Indicators](https://msfd.eu/knowseas/guidelines/3-INDICATORS-Guideline.pdf)
    or [Habitats
    Directive](https://ec.europa.eu/environment/nature/conservation/species/habitats_dir_en.htm)
    and [CITES](https://cites.org/eng/app/index.php) Annexes.

Or create your own selection using the [EMODnet Biology
toolbox](http://www.emodnet-biology.eu/toolbox). Just copy the
webservice URL and paste in R.

## Installation

You can install the development version from GitHub with `devtools`:

``` r
devtools::install_github("lifewatch/eurobis")
```

## Get occurrences

Use the `eurobis_occurrences()` family of functions to query data.

A basic example is:

``` r
library(eurobis)

# Get one single dataset
dataset <- eurobis_occurrences_basic(dasid = 8045)
#> Loading ISO 19139 XML schemas...
#> Loading ISO 19115 codelists...
#> Loading IANA mime types...
#> No encoding supplied: defaulting to UTF-8.
#> Downloading: 8.2 kB     Downloading: 8.2 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 540 B     Downloading: 540 B     Downloading: 550 B     Downloading: 550 B     Downloading: 550 B     Downloading: 550 B     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB
dplyr::glimpse(dataset)
#> Rows: 52
#> Columns: 11
#> $ gml_id                        <fct> eurobis-obisenv_basic.fid--69058bcf_180a…
#> $ id                            <int> 28965233, 28965282, 28965532, 28965710, …
#> $ datasetid                     <chr> "http://www.emodnet-biology.eu/data-cata…
#> $ datecollected                 <dttm> 2020-05-04, 2020-08-09, 2019-12-12, 202…
#> $ decimallongitude              <dbl> -8.73964, -8.73964, -8.73902, -8.73902, …
#> $ decimallatitude               <dbl> 40.61847, 40.61847, 40.61773, 40.61773, …
#> $ coordinateuncertaintyinmeters <dbl> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5…
#> $ scientificname                <chr> "Zostera marina", "Zostera marina", "Zos…
#> $ aphiaid                       <chr> "http://marinespecies.org/aphia.php?p=ta…
#> $ scientificnameaccepted        <chr> "Zostera subg. Zostera marina", "Zostera…
#> $ geometry                      <POINT [°]> POINT (-8.73964 40.61847), POINT (…
```

To see the list of datasets, use:

``` r
eurobis_list_datasets()
#> # A tibble: 1,213 × 2
#>    id    name                                                                   
#>    <chr> <chr>                                                                  
#>  1 5685  1507-1997 Paul F. Clark North East Atlantic Crab Atlas                 
#>  2 5688  1778-1998 Ivor Rees North Wales Marine Fauna Ad-hoc sightings shore an…
#>  3 5666  1915-2016 Marine Strategy Framework Directive (MSFD) Collation of inva…
#>  4 1884  2005-Ongoing UK MarLIN Shore Thing timed search results                
#>  5 6430  2009 University of Plymouth Wave Hub, Cornwall towed underwater video …
#>  6 6421  2010 University of Plymouth Guernsey towed underwater video benthic su…
#>  7 6693  2011 University of Plymouth Falmouth towed underwater video maerl and …
#>  8 6691  2012-2013 University of Plymouth Falmouth maerl bed infauna and sedime…
#>  9 5670  2012-ongoing UK Offshore Marine Conservation Zone (MCZ) Survey Data    
#> 10 6692  2012 University of Plymouth Falmouth towed underwater video maerl and …
#> # … with 1,203 more rows
```

For detailed information run:

``` r
help(eurobis_occurrences)
```

## Query by traits

Use the `functional_group` argument:

``` r
# Get one single dataset
dataset <- eurobis_occurrences_basic(dasid = 8045, functional_groups = "angiosperms")
#> Downloading: 8.2 kB     Downloading: 8.2 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 8.6 kB     Downloading: 540 B     Downloading: 540 B     Downloading: 550 B     Downloading: 550 B     Downloading: 550 B     Downloading: 550 B     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB     Downloading: 1.5 kB
dplyr::glimpse(dataset)
#> Rows: 52
#> Columns: 11
#> $ gml_id                        <fct> eurobis-obisenv_basic.fid--69058bcf_180a…
#> $ id                            <int> 28965233, 28965282, 28965532, 28965710, …
#> $ datasetid                     <chr> "http://www.emodnet-biology.eu/data-cata…
#> $ datecollected                 <dttm> 2020-05-04, 2020-08-09, 2019-12-12, 202…
#> $ decimallongitude              <dbl> -8.73964, -8.73964, -8.73902, -8.73902, …
#> $ decimallatitude               <dbl> 40.61847, 40.61847, 40.61773, 40.61773, …
#> $ coordinateuncertaintyinmeters <dbl> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5…
#> $ scientificname                <chr> "Zostera marina", "Zostera marina", "Zos…
#> $ aphiaid                       <chr> "http://marinespecies.org/aphia.php?p=ta…
#> $ scientificnameaccepted        <chr> "Zostera subg. Zostera marina", "Zostera…
#> $ geometry                      <POINT [°]> POINT (-8.73964 40.61847), POINT (…
```

See the full list of queriable traits in the exported dataset
`species_traits`:

``` r
tibble::as_tibble(species_traits)
#> # A tibble: 32 × 4
#>    category                      group            selection     selectid     
#>    <chr>                         <chr>            <chr>         <chr>        
#>  1 Species group                 Functional group algae         Algae        
#>  2 Species group                 Functional group angiosperms   Angiosperms  
#>  3 Species group                 Functional group benthos       Benthos      
#>  4 Species group                 Functional group birds         Birds        
#>  5 Species group                 Functional group mammals       Mammals      
#>  6 Species group                 Functional group phytoplankton phytoplankton
#>  7 Species group                 Functional group pisces        pisces       
#>  8 Species group                 Functional group reptiles      Reptiles     
#>  9 Species group                 Functional group zooplankton   zooplankton  
#> 10 Species importance to society CITES Annex      I             28_280_0     
#> # … with 22 more rows
```

## Query by location

You can also filter by location, either using the Marine Regions
Gazetteer Identifier (MRGID) or passing any polygon as Well Known Text.

``` r
eurobis_occurrences_basic(mrgid = 5688, geometry = "POLYGON ((-9.099426 40.33016, -9.099426 40.9788, -8.366089 40.9788, -8.366089 40.33016, -9.099426 40.33016))")
```

To help drawing the area of your interest, you can use
`eurobis_map_draw()`. You can draw here a polygon interactively:

``` r
selected_area <- eurobis_map_draw()
#> POLYGON ((-9.099426 40.33016, -9.099426 40.9788, -8.366089 40.9788, -8.366089 40.33016, -9.099426 40.33016))

eurobis_occurrences_full(geometry = selected_area)
```

To help choosing the MRGID from Marine Regions, see the list of
queriable regions with:

``` r
eurobis_list_regions()
#> # A tibble: 303 × 3
#>    id    nameEN                            placetype                           
#>    <chr> <chr>                             <chr>                               
#>  1 21899 Adriatic Sea                      Marine Ecoregion of the World (MEOW)
#>  2 3314  Adriatic Sea                      IHO Sea Area                        
#>  3 3315  Aegean Sea                        IHO Sea Area                        
#>  4 21900 Aegean Sea                        Marine Ecoregion of the World (MEOW)
#>  5 5670  Albanian Exclusive Economic Zone  EEZ                                 
#>  6 25614 Albanian part of the Adriatic Sea Marine Region                       
#>  7 25622 Albanian part of the Ionian Sea   Marine Region                       
#>  8 21897 Alboran Sea                       Marine Ecoregion of the World (MEOW)
#>  9 3324  Alboran Sea                       IHO Sea Area                        
#> 10 8378  Algerian Exclusive Economic Zone  EEZ                                 
#> # … with 293 more rows
```

Or select the MRGIDs of you interest with the family of functions
`eurobis_map_regions_*`: these will open a leaflet map including the
layers, read via Web Map Services (WMS).

``` r
# MEOW Ecoregions
eurobis_map_regions_ecoregions()

# Exclusive Economic Zones (EEZ)
eurobis_map_regions_eez()

# International Hydrographic Office areas (IHO)
eurobis_map_regions_iho()

# Marine Regions intersection of EEZ and IHO. Named as Marine Region in eurobis_list_regions()
eurobis_map_regions_eez_iho()

# EMODnet-Biology Reporting Areas
eurobis_map_regions_reportingareas()
```

See the manual with:

``` r
help(eurobis_map_regions)
```

Note that passing both an MRGID and a geometry does not restrict to the
selected area within the MRGID record, but adds both data fetched from
the selected data and the MRGID record.

## Why an EurOBIS R package? Didn’t exist an OBIS package already?

Yes, you could also use the [OBIS R
package](https://github.com/iobis/robis) `robis`. The main advantage of
the `eurobis` R package is the functionality to query on species traits.

## Disclaimer

If data are extracted from the EMODnet Biology for secondary analysis
resulting in a publication, the appropriate source should be cited.

The downloaded data should be cited as: EMODnet Biology (yyyy) Fulll
Occurrence Data and parameters downloaded from the EMODnet Biology
Project (www.emodnet-biology.eu). Available online at
www.emodnet-biology.eu/toolbox, consulted on yyyy-mm-dd.

Regarding the citation of the individual datasets, the following
guidelines should be taken into account:

  - If any individual data source of EurOBIS constitutes a significant
    proportion of the downloaded and used records (e.g. more than 10% of
    the data is derived from a single source), the individual data
    source should also be cited.
  - If any individual data source of EurOBIS constitutes a substantial
    proportion of the downloaded and used records (e.g. more than 25% of
    the data is derived from a single source or the data is essential to
    arrive at the conclusion of the analysis), the manager or custodian
    of this data set should be contacted.
  - In any case, it may be useful to contact the data custodian
    directly. The data custodian might have additional data available
    that may strengthen the analysis or he/she might be able to provide
    additional helpful information that may not be apparent from the
    provided metadata.
  - The data may not be redistributed without the permission of the
    appropriate data owners. If data are extracted from the EMODnet Data
    Portal for redistribution, please contact us at <bio@emodnet.eu>.

[![LifeWatch.be](https://raw.githubusercontent.com/lifewatch/eurobis/master/fig/LifeWatch_banner_test.PNG)](http://www.lifewatch.be/)
