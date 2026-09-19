library(sf)
library(ggplot2)
library(rnaturalearth)
library(rnaturalearthdata)
library(giscoR)
library(ggpattern)

# Europa
# Landen van Europa (hoge kwaliteit)
europe <- gisco_get_countries(
  resolution = "01",
  epsg = 4326
)


# België
belgium <- subset(europe, NAME_ENGL == "Belgium")

# Vlaanderen
# Vlaanderen
flanders <- gisco_get_nuts(
  country = "BE",
  nuts_level = 1,
  year = "2021",
  resolution = "01"
)

flanders <- subset(flanders, NUTS_NAME == "Vlaams Gewest")

# Kaart
ggplot() +
  # Zee / achtergrond
  annotate(
    "rect",
    xmin = -1.5, xmax = 9,
    ymin = 48.0, ymax = 53.5,
    fill = "#D6ECF5",
    colour = NA
  ) +
  
  # Landen
  geom_sf(
    data = europe,
    fill = "grey90",
    colour = "grey50",
    linewidth = 0.3
  ) +
  
  # België
  geom_sf(
    data = belgium,
    fill = "grey70",
    colour = "black",
    linewidth = 0.8
  ) +
  
  # Vlaanderen met arcering
  geom_sf_pattern(
    data = flanders,
    fill = "grey50",
    colour = "black",
    linewidth = 0.8,
    pattern = "stripe",
    pattern_angle = 45,
    pattern_density = 0.3,
    pattern_spacing = 0.04,
    pattern_colour = "black"
  ) +
  
  coord_sf(
    xlim = c(-1.5, 9.0),
    ylim = c(48.0, 53.5),
    expand = FALSE
  ) +
  
  theme_void()
