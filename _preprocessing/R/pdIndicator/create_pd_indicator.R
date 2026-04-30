#waarden geometry
library(sf)
library(dplyr)

#waarden pd-indicator
pd_cube_Fl_1km <- read.csv("./_preprocessing/data/interim/pd_indicator/pd_cube_flanders_1km.csv")

pd_cube_Fl_5km <- read.csv("./_preprocessing/data/interim/pd_indicator/pd_cube_flanders_5km.csv")

pd_loss_cube_Fl_1km <- read.csv("./_preprocessing/data/interim/pd_indicator/pd_loss_cube_1km.csv")

pd_loss_cube_Fl_5km <- read.csv("./_preprocessing/data/interim/pd_indicator/pd_loss_cube_5km.csv")

geojson_Vl_1km <- read_sf("./_preprocessing/data/raw/spatial/EEA_1km_Flanders_union.geojson")

geojson_Vl_5km <- read_sf("./_preprocessing/data/raw/spatial/EEA_5km_Flanders_union.geojson")

pd_Vl_1km <- geojson_Vl_1km %>%
  left_join(pd_cube_Fl_1km, by = c("CELLCODE" = "eeacellcode"))

pd_Vl_5km <- geojson_Vl_5km %>%
  left_join(pd_cube_Fl_5km, by = c("cellCode" = "eeacellcode"))

pd_loss_1km <- geojson_Vl_1km %>%
  left_join(pd_loss_cube_Fl_1km, by = c("CELLCODE" = "eeacellcode"))

pd_loss_5km <- geojson_Vl_5km %>%
  left_join(pd_loss_cube_Fl_5km, by = c("cellCode" = "eeacellcode"))

write_sf(pd_Vl_1km, "~/GitHub/Flanders_use_case/src/pdIndicator/pd_Vl_1km.geojson")
write_sf(pd_Vl_5km, "~/GitHub/Flanders_use_case/src/pdIndicator/pd_Vl_5km.geojson")
write_sf(pd_loss_1km, "~/GitHub/Flanders_use_case/src/pdIndicator/pd_loss_Vl_1km.geojson")
write_sf(pd_loss_5km, "~/GitHub/Flanders_use_case/src/pdIndicator/pd_loss_Vl_5km.geojson")
