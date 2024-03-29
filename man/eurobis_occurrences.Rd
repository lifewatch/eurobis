% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/eurobis_occurrences.R
\name{eurobis_occurrences}
\alias{eurobis_occurrences}
\alias{eurobis_occurrences_basic}
\alias{eurobis_occurrences_full}
\alias{eurobis_occurrences_full_and_parameters}
\alias{eurobis_occurrences_count}
\title{Get EurOBIS data by using the EMODnet-Biology webservices}
\usage{
eurobis_occurrences(
  type,
  url = NULL,
  mrgid = NULL,
  geometry = NULL,
  dasid = NULL,
  start_date = NULL,
  end_date = NULL,
  aphiaid = NULL,
  scientific_name = NULL,
  functional_groups = NULL,
  cites = NULL,
  habitats_directive = NULL,
  iucn_red_list = NULL,
  msdf_indicators = NULL,
  paging = FALSE,
  paging_length = 50000,
  verbose = TRUE,
  ...
)

eurobis_occurrences_basic(...)

eurobis_occurrences_full(...)

eurobis_occurrences_full_and_parameters(...)

eurobis_occurrences_count(...)
}
\arguments{
\item{type}{Type of data, one of c('basic', 'full', 'full_and_parameters'). You 
can use one of the wrappers:

- \code{\link{eurobis_occurrences_basic}}
- \code{\link{eurobis_occurrences_full}}
- \code{\link{eurobis_occurrences_full_and_parameters}}

More info at: \url{https://www.emodnet-biology.eu/emodnet-data-format}

You can also see the number of occurrences that a query will return before performing the request with:

- \code{\link{eurobis_occurrences_count}}

See details for more information.}

\item{url}{A WFS request copied from the LifeWatch/EMODnet-Biology Download Toolbox. Use \code{\link{eurobis_download_toolbox}}}

\item{mrgid}{Marine Regions Gazetteer unique identifier. See list of available regions with \code{\link{eurobis_list_regions}} and 
visualize with \code{\link{eurobis_map_regions}}}

\item{geometry}{a WKT geometry string or sf object with the region of interest. You can draw a polygon interactively 
with \code{\link{eurobis_map_draw}}}

\item{dasid}{IMIS dataset unique identifier. See list of available datasets with \code{\link{eurobis_list_datasets}}}

\item{start_date}{Start date of occurrences. Format YYYY-MM-DD.}

\item{end_date}{End date of occurrences. Format YYYY-MM-DD.}

\item{aphiaid}{WoRMS taxon unique identifier. See \url{https://www.marinespecies.org/} and \url{https://docs.ropensci.org/worrms/}}

\item{scientific_name}{Taxon name. It is matched with WoRMS on the fly. Ignored if aphiaid is provided.}

\item{functional_groups}{Functional groups available in WoRMS: See \code{eurobis::species_traits}.}

\item{cites}{CITES Annex. See \code{eurobis::species_traits}.}

\item{habitats_directive}{Habitats Directive Annex. See \code{eurobis::species_traits}.}

\item{iucn_red_list}{IUCN Red List Category. See \code{eurobis::species_traits}.}

\item{msdf_indicators}{Marine Strategy Directive Framework indicators. See \code{eurobis::species_traits}.}

\item{paging}{If TRUE, the data will be requested on chunks. Use for large requests. See details.}

\item{paging_length}{Size of chunks in number of rows. Default 50K. See details.}

\item{verbose}{set to FALSE to hide the info messages}

\item{...}{Any parameters to pass to  \code{ows4R} get feature request (e.g. cql_filter or parallel)}
}
\value{
a tibble or sf object with eurobis data
}
\description{
Get EurOBIS data by using the EMODnet-Biology webservices
}
\details{
If you want to perform a very large request, it is likely that this will take a long time to complete or even not 
work at all. In this case, the best approach is to first check the number of occurrences that will be returned by 
the query with \code{\link{eurobis_occurrences_count}}. 

If this number is high (e.g. more than 500K), you can set \code{paging = TRUE} to download the data in smaller chunks. 
This will still take time, but it is less likely to break the service by using several small request than one large one. 

You can set the size of the data chunk with  \code{paging_length}. The largest the chunk, the faster you download the 
data, but also more likely to break the service.
}
\examples{
\dontrun{
# Get dataset with ID 8045
# See also ?eurobis_list_datasets
test <- eurobis_occurrences_basic(dasid = 8045)

# Get full dataset with ID 8045
test <- eurobis_occurrences_full(dasid = 8045)

# Get full dataset with ID 8045 including extra measurements or facts 
test <- eurobis_occurrences_full_and_paremeters(dasid = 8045)

# Get occurrences from Zostera marina in the ecoregion Alboran Sea (MRGID 21897)
# See also ?eurobis_list_regions
test <- eurobis_occurrences_full(mrgid = 21897, scientific_name = "Zostera marina")

# Get zooplankton occurrences from the region of your choice
# See ?eurobis_map_mr and ?eurobis::species_traits
my_area <- eurobis_map_draw()
test <- eurobis_occurrences_basic(geometry = my_area, functional_groups = "zooplankton")

# Get occurrences from the Continuous Plankton Recorder (dataset id 216) in January 2016
test <- eurobis_occurrences_basic(dasid = 216, start_date = "2016-01-01", end_date = "2016-01-31")
}
}
