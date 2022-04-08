## code to prepare `species_traits` dataset
## insert as internal data
## this gets all the species traits in which users can query
## includes functional groups (benthos...) and special classifications (IUCN Red List, MSDF...)

library("odbc")

getdata = function(con, querry) {
  dbGetQuery(con, querry) 
} 

con <- dbConnect(odbc::odbc(), "db", uid="user", pwd="password")

query <- "
WITH T1 AS(
  SELECT category, 
       CASE WHEN category = 'Species importance to society' THEN \"group\"
            WHEN category = 'Species group' THEN 'Functional group'
            ELSE NULL END AS \"group\", 
       selection, selectid
  FROM eurobis.taxa_selection 
)
SELECT *
FROM T1
WHERE \"group\" IS NOT NULL
ORDER BY category, \"group\", selection
"

species_traits <- getdata(con, query)

dbDisconnect(con)

usethis::use_data(species_traits, internal = TRUE, overwrite = TRUE)
