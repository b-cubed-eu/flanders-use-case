
library('rgbif')


# occ_download_sql_prep("SELECT datasetKey, countryCode, COUNT(*) FROM occurrence WHERE continent = 'EUROPE' GROUP BY datasetKey, countryCode")
occ_download_sql("SELECT gbifid,countryCode FROM occurrence 
                  WHERE genusKey = 2435098")

occ_download_wait('0002874-251025141854904')

d <- occ_download_get('0002874-251025141854904') %>%
  occ_download_import()



sql <-
 "
SELECT 
 genus
FROM 
occurrence
WHERE occurrenceStatus = 'PRESENT'
AND countryCode = 'PL'
AND \"year\" >= 2024
AND kingdomKey = 1
AND hasCoordinate = TRUE
"
  
# nolint start: line_length_linter.
sql_lissa <- 



#test sql Lisa

test <- 

"SELECT
kingdom,
kingdomkey,
phylum,
phylumkey,
class,
classkey,
\"order\",
orderkey,
family,
familykey,
genus,
genuskey,
species,
specieskey,
PRINTF('%04d-%02d-%02d', \"year\", \"month\", \"day\") yearmonthday,
GBIF_EEARGCODE(1000, decimallatitude, decimallongitude, COALESCE(coordinateuncertaintyinmeters, 1000)) eeacellcode,
IF(ISNULL(orderkey), NULL, SUM(COUNT(*)) OVER (
  PARTITION BY orderkey, GBIF_EEARGCODE(1000, decimallatitude, decimallongitude, COALESCE(coordinateuncertaintyinmeters, 1000)), PRINTF('%04d-%02d-%02d', \"year\", \"month\", \"day\"))) ordercount,
IF(ISNULL(familykey), NULL, SUM(COUNT(*)) OVER (
  PARTITION BY familykey, GBIF_EEARGCODE(1000, decimallatitude, decimallongitude, COALESCE(coordinateuncertaintyinmeters, 1000)), PRINTF('%04d-%02d-%02d', \"year\", \"month\", \"day\"))) familycount,
IF(ISNULL(genuskey), NULL, SUM(COUNT(*)) OVER (
  PARTITION BY genuskey, GBIF_EEARGCODE(1000, decimallatitude, decimallongitude, COALESCE(coordinateuncertaintyinmeters, 1000)), PRINTF('%04d-%02d-%02d', \"year\", \"month\", \"day\"))) genuscount,
COUNT(*) occurrences,
MIN(GBIF_TEMPORALUNCERTAINTY(eventdate, eventtime)) mintemporaluncertainty,
MIN(COALESCE(coordinateuncertaintyinmeters, 1000)) mincoordinateuncertaintyinmeters
FROM
occurrence
WHERE
(occurrence.level0gid IN ('BEL.2_1', 'BEL.1.1.1_1') OR occurrence.level1gid IN ('BEL.2_1', 'BEL.1.1.1_1') OR occurrence.level2gid IN ('BEL.2_1', 'BEL.1.1.1_1') OR occurrence.level3gid IN ('BEL.2_1', 'BEL.1.1.1_1'))
AND occurrence.occurrencestatus = 'PRESENT'
AND (occurrence.taxonkey IN ('196', '220') OR occurrence.acceptedtaxonkey IN ('196', '220') OR occurrence.kingdomkey IN ('196', '220') OR occurrence.phylumkey IN ('196', '220') OR occurrence.classkey IN ('196', '220') OR occurrence.orderkey IN ('196', '220') OR occurrence.familykey IN ('196', '220') OR occurrence.genuskey IN ('196', '220') OR occurrence.specieskey IN ('196', '220'))
AND (occurrence.\"year\" >= 1975 AND occurrence.\"year\" <= 2025)
AND occurrence.hasgeospatialissues = FALSE
AND NOT GBIF_STRINGARRAYCONTAINS(occurrence.issue, 'TAXON_MATCH_FUZZY', TRUE)
AND NOT occurrence.basisofrecord IN ('FOSSIL_SPECIMEN', 'LIVING_SPECIMEN')
AND (occurrence.specieskey IS NOT NULL AND occurrence.\"year\" IS NOT NULL AND occurrence.\"month\" IS NOT NULL AND occurrence.\"day\" IS NOT NULL AND occurrence.hascoordinate = TRUE)
GROUP BY
occurrence.kingdom,
occurrence.kingdomkey,
occurrence.phylum,
occurrence.phylumkey,
occurrence.class,
occurrence.classkey,
occurrence.\"order\",
occurrence.orderkey,
occurrence.family,
occurrence.familykey,
occurrence.genus,
occurrence.genuskey,
occurrence.species,
occurrence.specieskey,
PRINTF('%04d-%02d-%02d', \"year\", \"month\", \"day\"),
GBIF_EEARGCODE(1000, decimallatitude, decimallongitude, COALESCE(coordinateuncertaintyinmeters, 1000))"

occ_download_sql_prep(test)

occ_download_sql(test)
