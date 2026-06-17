#---------------------------------------------------------------------
# READ IN NECESSARY SOURCE CODE, PACKAGES AND DATA
#---------------------------------------------------------------------

# Read in necessary source code, packages and data

# files <- list.files(path = "R", pattern = "\\.R$", full.names = TRUE)
# sapply(files, source)
library(ape)
library(dplyr)
library(httr)
library(jsonlite)
library(rgbif)
library(purrr)
library(progressr)
library(furrr)


# read in all observed species in Belgium (natuurpunt)
belgium_all_observed_taxon <-
  read.csv('_preprocessing/data/raw/dwca-natuurpunt-natagora-checklist-v1.3/taxon.txt',
           stringsAsFactors = FALSE, sep = "\t")
belgium_all_observed_distr <-
  read.csv('_preprocessing/data/raw/dwca-natuurpunt-natagora-checklist-v1.3/distribution.txt',
           stringsAsFactors = FALSE, sep = "\t")
belgium_all_observed_distr <-
  belgium_all_observed_distr[belgium_all_observed_distr$locationID=='ISO_3166-2:BE',]
belgium_all_observed <-
  left_join(belgium_all_observed_taxon, belgium_all_observed_distr, by = 'id')
belgium_animalia_obs <-
  belgium_all_observed[belgium_all_observed$kingdom=="Animalia",]
belgium_animalia_obs_native <-
  belgium_animalia_obs[belgium_animalia_obs$establishmentMeans=='native',]

# determine corresponding gbif specieskeys
species_list <- belgium_animalia_obs_native$scientificName
# be_plants_native <- name_backbone_checklist(name = specieslist)
# rgbif::name_backbone_checklist() currently doesn't return acceptedUsageKey
# alternative:

match_species <- function(sp_name, dataset_key) {

  res <- tryCatch(
    GET(
      "https://api.gbif.org/v1/species/match",
      query = list(name = sp_name, datasetKey = dataset_key),
      timeout(10)
    ),
    error = function(e) NULL
  )

  if (is.null(res) || status_code(res) != 200) {
    return(tibble(
      verbatim_name = sp_name,
      usageKey = NA_integer_,
      scientificName = NA_character_,
      status = NA_character_,
      rank = NA_character_,
      matchType = NA_character_,
      confidence = NA_real_,
      acceptedUsageKey = NA_integer_,
      kingdomKey = NA_integer_,
      phylumKey = NA_integer_,
      classKey = NA_integer_,
      orderKey = NA_integer_,
      familyKey = NA_integer_
    ))
  }

  data <- fromJSON(content(res, "text", encoding = "UTF-8"), flatten = TRUE)

  tibble(
    verbatim_name   = sp_name,
    usageKey          = data$usageKey %||% NA_integer_,
    scientificName    = data$scientificName %||% NA_character_,
    status            = data$status %||% NA_character_,
    rank              = data$rank %||% NA_character_,
    matchType         = data$matchType %||% NA_character_,
    confidence        = data$confidence %||% NA_real_,
    acceptedUsageKey  = data$acceptedUsageKey %||% NA_integer_,
    kingdomKey        = data$kingdomKey %||% NA_integer_,
    phylumKey         = data$phylumKey %||% NA_integer_,
    classKey          = data$classKey %||% NA_integer_,
    orderKey          = data$orderKey %||% NA_integer_,
    familyKey         = data$familyKey %||% NA_integer_
  )
}

dataset_key <- "d7dddbf4-2cf0-4f39-9b2a-bb099caae36c"

start_time <- Sys.time()
be_animalia_native <- future_map_dfr(
  species_list,
  match_species,
  dataset_key = dataset_key,
  .options = furrr_options(seed = TRUE)
)

end_time <- Sys.time()

cat("Total runtime:", round(difftime(end_time, start_time, units = "mins"), 2),
    "minutes\n")

be_animalia_native <- be_animalia_native %>%
  mutate(
    acceptedUsageKey = if_else(
      status == "ACCEPTED",
      usageKey,
      acceptedUsageKey
    )
  )

be_animalia_native <- be_plants_native[be_animalia_native$matchType %in%
                                       c("EXACT", "FUZZY"), ]

write.csv(be_animalia_native,"_preprocessing/data/interim/be_animalia_native.csv")
# read in from file
# be_plants_native <- read.csv('data/intermediate/be_plants_native.csv',
