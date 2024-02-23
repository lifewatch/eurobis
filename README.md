
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
eurobis_occurrences_basic(dasid = 8045)
#> Loading ISO 19139 XML schemas...
#> Loading ISO 19115 codelists...
#> Loading IANA mime types...
#> No encoding supplied: defaulting to UTF-8.
#> ✔ Downloading layer: EMODnet EurOBIS Basic Occurrence Data
#> ℹ The Basic Occurrence Data download provides you data for the following 8 essential terms: datasetid, datecollected, decimallongitude, decimallatitude, coordinateuncertaintyinmeters, scientificname, aphiaid, scientificnameaccepted. For more information, please consult: https://www.emodnet-biology.eu/emodnet-data-format.
#> Simple feature collection with 52 features and 10 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -8.73964 ymin: 40.61773 xmax: -8.73902 ymax: 40.61899
#> CRS:           EPSG:4326
#> # A tibble: 52 × 11
#>    gml_id         id datas…¹ datecollected       decim…² decim…³ coord…⁴ scien…⁵
#>  * <fct>       <int> <chr>   <dttm>                <dbl>   <dbl>   <dbl> <chr>  
#>  1 eurobis-o… 3.68e7 https:… 2020-05-05 00:00:00   -8.74    40.6       5 Zoster…
#>  2 eurobis-o… 3.68e7 https:… 2019-12-13 00:00:00   -8.74    40.6       5 Zoster…
#>  3 eurobis-o… 3.68e7 https:… 2020-03-03 00:00:00   -8.74    40.6       5 Zoster…
#>  4 eurobis-o… 3.68e7 https:… 2019-12-13 00:00:00   -8.74    40.6       5 Zoster…
#>  5 eurobis-o… 3.68e7 https:… 2020-08-10 00:00:00   -8.74    40.6       5 Zoster…
#>  6 eurobis-o… 3.68e7 https:… 2020-08-10 00:00:00   -8.74    40.6       5 Zoster…
#>  7 eurobis-o… 3.68e7 https:… 2020-05-05 00:00:00   -8.74    40.6       5 Zoster…
#>  8 eurobis-o… 3.68e7 https:… 2020-05-05 00:00:00   -8.74    40.6       5 Zoster…
#>  9 eurobis-o… 3.68e7 https:… 2020-03-03 00:00:00   -8.74    40.6       5 Zoster…
#> 10 eurobis-o… 3.68e7 https:… 2020-05-05 00:00:00   -8.74    40.6       5 Zoster…
#> # … with 42 more rows, 3 more variables: aphiaid <chr>,
#> #   scientificnameaccepted <chr>, geometry <POINT [°]>, and abbreviated
#> #   variable names ¹​datasetid, ²​decimallongitude, ³​decimallatitude,
#> #   ⁴​coordinateuncertaintyinmeters, ⁵​scientificname
```

For detailed information run:

``` r
help(eurobis_occurrences)
```

## Query by traits

Use the `functional_group` argument:

``` r
# Get one single dataset
eurobis_occurrences_basic(dasid = 8045, functional_groups = "angiosperms")
```

See the full list of queriable traits in the exported dataset
`species_traits`:

``` r
species_traits
#>                         category                    group
#> 1                  Species group         Functional group
#> 2                  Species group         Functional group
#> 3                  Species group         Functional group
#> 4                  Species group         Functional group
#> 5                  Species group         Functional group
#> 6                  Species group         Functional group
#> 7                  Species group         Functional group
#> 8                  Species group         Functional group
#> 9                  Species group         Functional group
#> 10 Species importance to society              CITES Annex
#> 11 Species importance to society              CITES Annex
#> 12 Species importance to society              CITES Annex
#> 13 Species importance to society Habitats Directive Annex
#> 14 Species importance to society Habitats Directive Annex
#> 15 Species importance to society   IUCN Red List Category
#> 16 Species importance to society   IUCN Red List Category
#> 17 Species importance to society   IUCN Red List Category
#> 18 Species importance to society          MSFD indicators
#> 19 Species importance to society          MSFD indicators
#> 20 Species importance to society          MSFD indicators
#> 21 Species importance to society          MSFD indicators
#> 22 Species importance to society          MSFD indicators
#> 23 Species importance to society          MSFD indicators
#> 24 Species importance to society          MSFD indicators
#> 25 Species importance to society          MSFD indicators
#> 26 Species importance to society          MSFD indicators
#> 27 Species importance to society          MSFD indicators
#> 28 Species importance to society          MSFD indicators
#> 29 Species importance to society          MSFD indicators
#> 30 Species importance to society          MSFD indicators
#> 31 Species importance to society          MSFD indicators
#> 32 Species importance to society          MSFD indicators
#>                                                             selection
#> 1                                                               algae
#> 2                                                         angiosperms
#> 3                                                             benthos
#> 4                                                               birds
#> 5                                                             mammals
#> 6                                                       phytoplankton
#> 7                                                              pisces
#> 8                                                            reptiles
#> 9                                                         zooplankton
#> 10                                                                  I
#> 11                                                                 II
#> 12                                                                III
#> 13                                                                 II
#> 14                                                                 IV
#> 15                                                     data deficient
#> 16                                                      least concern
#> 17                                                    near threatened
#> 18                                      Black Sea proposed indicators
#> 19                                HELCOM core biodiversity indicators
#> 20                   Mediterranean proposed indicators - Adriatic Sea
#> 21           Mediterranean proposed indicators - Aegean-Levantine Sea
#> 22                     Mediterranean proposed indicators - Ionian Sea
#> 23              Mediterranean proposed indicators - Mediterranean Sea
#> 24          Mediterranean proposed indicators - Western Mediterranean
#> 25    OSPAR candidate indicators: Bay of Biscay and the Iberian Coast
#> 26                            OSPAR candidate indicators: Celtic Seas
#> 27 OSPAR candidate indicators: Greater North Sea including outside EU
#> 28                              OSPAR candidate indicators: North Sea
#> 29           OSPAR common indicators: Bay of Biscay and Iberian Coast
#> 30                               OSPAR common indicators: Celtic Seas
#> 31                         OSPAR common indicators: Greater North Sea
#> 32    OSPAR common indicators: Greater North Sea including outside EU
#>         selectid
#> 1          Algae
#> 2    Angiosperms
#> 3        Benthos
#> 4          Birds
#> 5        Mammals
#> 6  phytoplankton
#> 7         pisces
#> 8       Reptiles
#> 9    zooplankton
#> 10      28_280_0
#> 11      28_281_0
#> 12      28_282_0
#> 13      26_269_0
#> 14      26_271_0
#> 15         1_8_3
#> 16         1_7_3
#> 17         1_6_3
#> 18     23_285_41
#> 19     23_285_29
#> 20     23_285_31
#> 21     23_285_32
#> 22     23_285_33
#> 23     23_285_34
#> 24     23_285_30
#> 25     23_285_35
#> 26     23_285_36
#> 27     23_285_37
#> 28     23_285_38
#> 29     23_285_44
#> 30     23_285_45
#> 31     23_285_46
#> 32     23_285_40
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
