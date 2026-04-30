############################
# Read in packages and files
############################

library(readr)
library(sf)
library(dplyr)
library(ggplot2)
library(grDevices)
tree_path <- "data/oo_330891.tre"
tree <- read.nexus(tree_path)
tree$tip.label <- lapply(tree$tip.label, function(label){gsub("_", " ", label)})

grid_path <- "data/shpfiles/EEA_BE_1km/EEA_BE_1km.shp"
grid <- sf::st_read(grid_path)
cube_flanders <- read_csv("data/Angiosperm_data_Flanders_1km.csv")
cube_flanders_nonthreatened <- read_csv("data/Angiosperm_Flanders_1km_nonthreatened.csv")

#-----------------------------------------------------------------------------
# General steps to filter out species not in tree (compare to PD)
#-----------------------------------------------------------------------------

# Find GBIF id's corresponding to tip labels

# taxonmatch(tree)
tree_labels <- tree$tip.label
tree_labels <- unlist(tree_labels)

plan(multisession, workers = 10)

dataset_key <- "d7dddbf4-2cf0-4f39-9b2a-bb099caae36c"

start_time <- Sys.time()

matched_all <- future_map_dfr(
  tree_labels,
  match_species,
  dataset_key = dataset_key,
  .options = furrr_options(seed = TRUE)
)

end_time <- Sys.time()

cat("Total runtime:", round(difftime(end_time, start_time, units = "mins"), 2),
    "minutes\n")

matched_all <- matched_all %>%
  mutate(
    acceptedUsageKey = if_else(
      status == "ACCEPTED",
      usageKey,
      acceptedUsageKey
    )
  )

matched <- matched_all[matched_all$matchType %in% c("EXACT", "FUZZY"), ]
# write.csv(matched,"data/intermediate/matched_exactfuzzy_Steventree.csv")
# read file without calculating again:
# matched <- read.csv('data/intermediate/matched_Steventree.csv',
# stringsAsFactors = FALSE, sep = ",")

#-----------------------------------------------------------------------------
# CALCULATION richness cube Flanders
#-----------------------------------------------------------------------------

cube <- cube_flanders

# Append orig_tiplabel to cube
source("R/append_ott_id.R")
source("R/check_completeness.R")

mcube <- append_ott_id(tree, cube, matched)
head(mcube)

# not_in_tree <- mcube[is.na(mcube$verbatim_name), ]
not_in_tree <- mcube[is.na(mcube$verbatim_name), ]
head(not_in_tree)
unique <- unique(not_in_tree$species)
length(unique)
# Schrijf lijst van 222 soorten die wel in cube maar niet in tree voorkomen weg
# write.csv(unique,"data/intermediate/not_in_tree_update.csv")

# Remove occurrences that can't be matched to a tree species
nrow(mcube)
mcube <- mcube %>% dplyr::filter(!is.na(verbatim_name))


source("R/aggregate_cube.R")
aggr_cube <- aggregate_cube(mcube)
richness_cube <- aggr_cube %>% mutate(sp_richness = map_int(specieskeys, length))
richness_cube <- richness_cube %>% select(eeacellcode, sp_richness)
write.csv(richness_cube, "output/sp_richness_flanders_1km.csv")



#-----------------------------------------------------------------------------
# CALCULATION richness cube Flanders nonthreatened
#-----------------------------------------------------------------------------

cube <- cube_flanders_nonthreatened

# Append orig_tiplabel to cube
source("R/append_ott_id.R")
source("R/check_completeness.R")

mcube <- append_ott_id(tree, cube, matched)
head(mcube)

# not_in_tree <- mcube[is.na(mcube$verbatim_name), ]
not_in_tree <- mcube[is.na(mcube$verbatim_name), ]
head(not_in_tree)
unique <- unique(not_in_tree$species)
length(unique)
# Schrijf lijst van 222 soorten die wel in cube maar niet in tree voorkomen weg
# write.csv(unique,"data/intermediate/not_in_tree_update.csv")

# Remove occurrences that can't be matched to a tree species
nrow(mcube)
mcube <- mcube %>% dplyr::filter(!is.na(verbatim_name))


source("R/aggregate_cube.R")
aggr_cube <- aggregate_cube(mcube)
richness_cube <- aggr_cube %>% mutate(sp_richness = map_int(specieskeys, length))
head(richness_cube)
richness_cube <- richness_cube %>% select(eeacellcode, sp_richness)
write.csv(richness_cube, "output/sp_richness_flanders_nonthreatened_1km.csv")

##########################
# calculate pd loss cube
##########################
sp_richness_fl <- read_csv("output/sp_richness_flanders_1km.csv")
sp_richness_nonthreatened <- read_csv("output/sp_richness_flanders_nonthreatened_1km.csv")
richness_loss_cube <- left_join(sp_richness_fl,sp_richness_nonthreatened, by = "eeacellcode")
head(richness_loss_cube)
richness_loss_cube <- richness_loss_cube %>% mutate(richness_loss = sp_richness.x - sp_richness.y)

#########################
# generate pd_cube_geo
########################

pd_cube_geo <- right_join(grid, richness_loss_cube,
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
                   mapping = ggplot2::aes(fill = .data$richness_loss), colour = NA)+
  ggplot2::scale_fill_viridis_c(option = "B",) +
  # ggplot2::geom_sf(data = pa, fill = NA, color = "lightblue",
  # linewidth = 0.03) +
  ggplot2::coord_sf(xlim = c(bbox_expanded["xmin"], bbox_expanded["xmax"]),
                    ylim = c(bbox_expanded["ymin"], bbox_expanded["ymax"]),
                    expand = FALSE) +
  ggplot2::xlab("Longitude") + ggplot2::ylab("Latitude") +
  ggplot2::ggtitle(paste("Potential Species Diversity Loss of threatened Angiosperms in Flanders")) +
  ggplot2::theme(
    panel.grid.major = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "aliceblue"))

ggplot2::ggsave(filename = "output/richness_loss_map_1km.png", plot = pd_map, width = 10, height = 5)
sf::st_write(pd_cube_geo, "output/sprichness_loss_map_1km.shp")
