############################
# Read in packages and files
############################

library(readr)
library(sf)
library(dplyr)
library(ggplot2)
library(grDevices)
grid_path <- "data/shpfiles/EEA_BE_1km/EEA_BE_1km.shp"
grid <- sf::st_read(grid_path)
pd_cube_flanders <- read_csv("output/pd_cube_Flanders_1km.csv")
pd_cube_nonthreatened <- read_csv("output/pd_cube_Flanders_1km_nonthreatened.csv")

##########################
# calculate pd loss cube
##########################
pd_loss_cube <- left_join(pd_cube_flanders, pd_cube_nonthreatened, by = "eeacellcode")
head(pd_loss_cube)
pd_loss_cube <- pd_loss_cube %>% mutate(pd_loss= pd.x - pd.y)

#########################
# generate pd_cube_geo
########################

pd_cube_geo <- right_join(grid, pd_loss_cube,
                          by = join_by("CELLCOD" == "eeacellcode"))

# Set bounding box
  bbox <- sf::st_bbox(pd_cube_geo)

# Expand bounding box
expansion_factor <- 0.20
bbox_expanded <- c(
  xmin = as.numeric(bbox["xmin"]) -
    (as.numeric(bbox["xmax"]) - as.numeric(bbox["xmin"])) * expansion_factor,
  xmax = as.numeric(bbox["xmax"]) +
    (as.numeric(bbox["xmax"]) - as.numeric(bbox["xmin"])) * expansion_factor,
  ymin = as.numeric(bbox["ymin"]) -
    (as.numeric(bbox["ymax"]) - as.numeric(bbox["ymin"])) * expansion_factor,
  ymax = as.numeric(bbox["ymax"]) +
    (as.numeric(bbox["ymax"]) - as.numeric(bbox["ymin"])) * expansion_factor
)

# Read in country borders
world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf")
world_3035 <- sf::st_transform(world, crs = 3035)

# Initialize lists to store maps and indicators
plots <- list()
indicators <- list()

# Calculate global min and max PD values for consistent color scale
pd_min <- min(pd_cube_geo$pd_loss, na.rm = TRUE)
pd_max <- max(pd_cube_geo$pd_loss, na.rm = TRUE)

################################
##############################


pd_map <- ggplot2::ggplot() +
  ggplot2::geom_sf(data = world_3035, fill = "antiquewhite") +
  ggplot2::geom_sf(data = pd_cube_geo,
                   mapping = ggplot2::aes(fill = .data$pd_loss), colour = NA)+
  ggplot2::scale_fill_viridis_c(option = "B",) +
  # ggplot2::geom_sf(data = pa, fill = NA, color = "lightblue",
  # linewidth = 0.03) +
  ggplot2::coord_sf(xlim = c(bbox_expanded["xmin"], bbox_expanded["xmax"]),
                    ylim = c(bbox_expanded["ymin"], bbox_expanded["ymax"]),
                    expand = FALSE) +
  ggplot2::xlab("Longitude") + ggplot2::ylab("Latitude") +
  ggplot2::ggtitle(paste("Potential Phylogenetic Diversity Loss of threatened Angiosperms in Flanders")) +
  ggplot2::theme(
    panel.grid.major = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "aliceblue"))

ggplot2::ggsave(filename = "output/pd_loss_map_1km.png", plot = pd_map, width = 10, height = 5)
sf::st_write(pd_cube_geo, "output/pd_loss_map_1km.shp")
