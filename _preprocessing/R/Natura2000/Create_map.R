#Natura2000 versus nonNatura2000
#create map and determine total surface per category

library(sf)
library(leaflet)


Natura2000 <- read_sf('~/GitHub/Flanders_use_case/_preprocessing/data/raw/spatial/EEA_1km_Natura2000.geojson')
nonNatura2000 <- read_sf('~/GitHub/Flanders_use_case/_preprocessing/data/raw/spatial/EEA_1km_nonNatura2000.geojson')


map <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = Natura2000,
              fillColor = "green",
              color = "transparent",
              weight = 0,
              fillOpacity = 0.6) %>%
  addPolygons(data = nonNatura2000,
              fillColor = "red",
              color = "transparent",
              weight = 0,
              fillOpacity = 0.6)


#Oppervlakte Natura2000: 4267
#Oppervlakte nonNatura2000: 10105
