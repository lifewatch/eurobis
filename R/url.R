eurobis_url <- list(
  dataportal = list(
    wfs = "https://geo.vliz.be/geoserver/Dataportal/wfs"
  ),
  datatypes = list(
    basic = "Dataportal:eurobis-obisenv_basic",
    full = "Dataportal:eurobis-obisenv_full",
    full_and_parameters = "Dataportal:eurobis-obisenv",
    count = "Dataportal:eurobis-obisenv_count"
  ),
  imis = list(
    base_url = "https://www.vliz.be/imis"
  ),
  marineregions = list(
    gazetteer_rest = "https://marineregions.org/rest/",
    wfs_url = "https://geo.vliz.be/geoserver/MarineRegions/wfs",
    wms_url = "https://geo.vliz.be/geoserver/MarineRegions/wms"
  ),
  mr_layers = list(
    ecoregions = "Ecoregions:ecoregions", 
    iho = "MarineRegions:iho",
    eez = "MarineRegions:eez",
    eez_iho = "MarineRegions:eez_iho",
    reportingareas = "Emodnet:reportingareas" 
  ),
  info = list(
    datatype = "https://emodnet.ec.europa.eu/en/biology#biology-data-and-products-format",
    toolbox = "https://www.eurobis.org/toolbox",
    toolbox_api_endpoint = "https://www.eurobis.org/toolbox/en/download/"
  )
)
