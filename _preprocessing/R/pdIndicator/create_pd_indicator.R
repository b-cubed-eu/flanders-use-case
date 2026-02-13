#waarden pd-indicator
pd_cube_final <- read.csv("~/GitHub/Flanders_use_case/_preprocessing/data/interim/pd_cube_final.csv")

#waarden geometry
library(sf)
library(dplyr)

geojson_Vl <- read_sf("~/GitHub/Flanders_use_case/_preprocessing/data/raw/spatial/EEA_1km_Flanders_union.geojson")


pd_Vl <- geojson_Vl %>%
  left_join(pd_cube_final, by = c("CELLCODE" = "eeacellcode"))

write_sf(pd_Vl, "~/GitHub/Flanders_use_case/src/pd_Vl.geojson")
