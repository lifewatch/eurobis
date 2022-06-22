eurobis_url <- list(
  dataportal = list(
    wfs = "https://geo.vliz.be/geoserver/Dataportal/wfs",
    wms = "https://geo.vliz.be/geoserver/Dataportal/wms?"
  ),
  datatypes = list(
    basic = "Dataportal:eurobis-obisenv_basic",
    full = "Dataportal:eurobis-obisenv_full",
    full_and_parameters = "Dataportal:eurobis-obisenv",
    count = "Dataportal:eurobis-obisenv_count"
  ),
  grid = list(
    `1d` = "Dataportal:eurobis_grid_1d-obisenv",
    `30m` = "Dataportal:eurobis_grid_30m-obisenv",
    `15m` = "Dataportal:eurobis_grid_15m-obisenv",
    `6m` = "Dataportal:eurobis_grid_6m-obisenv"
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
    datatype = "https://www.emodnet-biology.eu/emodnet-data-format",
    toolbox = "https://www.emodnet-biology.eu/toolbox",
    toolbox_api_endpoint = "https://www.emodnet-biology.eu/toolbox/en/download/"
  )
)
