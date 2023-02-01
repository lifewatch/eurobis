
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Download data from EurOBIS using the LifeWatch/EMODnet-Biology Web Feature Services

<!-- badges: start -->

[![Funding](https://img.shields.io/static/v1?label=powered+by&message=lifewatch.be&labelColor=1a4e8a&color=f15922)](http://lifewatch.be)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/lifewatch/eurobis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/lifewatch/eurobis/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The `eurobis` R package allows you to download data from EurOBIS.

You can query on:

-   **Dataset**: provide the Integrated Marine Information System
    ([IMIS](https://www.vliz.be/en/integrated-marine-information-system))
    unique identifier for datasets
    [DasID](https://www.vliz.be/imis?page=webservices).
-   **Taxon**: use a scientific name (e.g. the sea turtle *Caretta
    caretta*) or a [WoRMS
    AphiaID](https://www.marinespecies.org/about.php#what_is_aphia)
    (e.g. [137205](https://www.marinespecies.org/aphia.php?p=taxdetails&id=137205))
-   **Traits**: get all occurrences that are benthos. Or zooplankton. Or
    both. Powered by [WoRMS](https://www.marinespecies.org/).
-   **Time**: just give start and end dates.
-   **Geographically**: it allows to query on more than 300 records from
    the [Marine Regions
    Gazetteer](https://marineregions.org/gazetteer.php) by giving the
    [MRGID](https://marineregions.org/mrgid.php). Or just pass the area
    of your interest as a polygon written in as [Well Known
    Text](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
-   Other important classifications as [IUCN Red
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
#> ✔ Downloading layer: EMODnet EurOBIS Basic Occurrence Data
#> ℹ The Basic Occurrence Data download provides you data for the following 8 essential terms: datasetid, datecollected, decimallongitude, decimallatitude, coordinateuncertaintyinmeters, scientificname, aphiaid, scientificnameaccepted. For more information, please consult: https://www.emodnet-biology.eu/emodnet-data-format.
dplyr::glimpse(dataset)
#> Rows: 52
#> Columns: 11
#> $ gml_id                        <chr> "eurobis-obisenv_basic.fid-632d47d4_1860…
#> $ id                            <int> 28840495, 28841810, 28837086, 28866685, …
#> $ datasetid                     <chr> "http://www.emodnet-biology.eu/data-cata…
#> $ datecollected                 <dttm> 2020-03-03 01:00:00, 2020-05-05 02:00:0…
#> $ decimallongitude              <dbl> -8.73914, -8.73948, -8.73902, -8.73948, …
#> $ decimallatitude               <dbl> 40.61804, 40.61899, 40.61773, 40.61899, …
#> $ coordinateuncertaintyinmeters <dbl> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5…
#> $ scientificname                <chr> "Zostera marina", "Zostera marina", "Zos…
#> $ aphiaid                       <chr> "http://marinespecies.org/aphia.php?p=ta…
#> $ scientificnameaccepted        <chr> "Zostera subg. Zostera marina", "Zostera…
#> $ geometry                      <POINT [°]> POINT (-8.73914 40.61804), POINT (…
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
#> ✔ Downloading layer: EMODnet EurOBIS Basic Occurrence Data
#> ℹ The Basic Occurrence Data download provides you data for the following 8 essential terms: datasetid, datecollected, decimallongitude, decimallatitude, coordinateuncertaintyinmeters, scientificname, aphiaid, scientificnameaccepted. For more information, please consult: https://www.emodnet-biology.eu/emodnet-data-format.
#> Warning in eurobis_occurrences(type = "basic", ...): There are 0 occurrences in
#> EurOBIS for this query at the moment
dplyr::glimpse(dataset)
#> Rows: 0
#> Columns: 11
#> $ gml_id                        <chr> 
#> $ id                            <int> 
#> $ datasetid                     <chr> 
#> $ datecollected                 <dttm> 
#> $ decimallongitude              <dbl> 
#> $ decimallatitude               <dbl> 
#> $ coordinateuncertaintyinmeters <dbl> 
#> $ scientificname                <chr> 
#> $ aphiaid                       <chr> 
#> $ scientificnameaccepted        <chr> 
#> $ geometry                      <GEOMETRY [°]>
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
queriable regions and their MRGIDs with the family of functions
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

-   If any individual data source of EurOBIS constitutes a significant
    proportion of the downloaded and used records (e.g. more than 10% of
    the data is derived from a single source), the individual data
    source should also be cited.
-   If any individual data source of EurOBIS constitutes a substantial
    proportion of the downloaded and used records (e.g. more than 25% of
    the data is derived from a single source or the data is essential to
    arrive at the conclusion of the analysis), the manager or custodian
    of this data set should be contacted.
-   In any case, it may be useful to contact the data custodian
    directly. The data custodian might have additional data available
    that may strengthen the analysis or he/she might be able to provide
    additional helpful information that may not be apparent from the
    provided metadata.
-   The data may not be redistributed without the permission of the
    appropriate data owners. If data are extracted from the EMODnet Data
    Portal for redistribution, please contact us at <bio@emodnet.eu>.

[![LifeWatch.be](https://raw.githubusercontent.com/lifewatch/eurobis/master/fig/LifeWatch_banner_test.PNG)](http://www.lifewatch.be/)
