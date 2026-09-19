# Load packages
library(tidyverse) # Data wrangling and visualisation
library(here)      # Relative paths
library(sf)        # Work with spatial data
library(rgbif)
library(dplyr)
library(ggplot2)

file <- occ_download_get("0015997-260721160103020")
data_total_1km<- occ_download_import(file)

names(data_total_1km)

FLANDERS_EEA_1km <- st_read('./_preprocessing/data/raw/spatial/EEA_1km_Flanders_union.geojson')

total <- data_total_1km%>%
  filter(eeacellcode%in%FLANDERS_EEA_1km$CELLCODE)



# B-Cubed inspired palette
bcubed <- c(
  "#005957", # donker teal (primary)
  "#6CDDB4", # licht mint / accent
  "#2E7D32",
  "#43A047",
  "#81C784",
  "#C8E6C9",
  "#FFFFFF"
)

theme_bcubed <- function() {
  theme_minimal(base_size = 13) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      legend.position = "bottom",
      plot.title = element_text(face = "bold"),
      axis.title = element_text(face = "bold")
    )
}

fig1 <- total %>%
  filter(year >= 1975) %>%
  group_by(year) %>%
  summarise(records = sum(occurrences), .groups = "drop") %>%
  ggplot(aes(year, records)) +
  geom_line(colour = "#005957", linewidth = 1.2) +
  geom_point(colour = "#005957", size = 2) +
  labs(
    x = "Year",
    y = "Number of records"
  ) +
  theme_minimal()

fig1

top10 <- total %>%
  filter(year >= 2000) %>%
  group_by(publisher) %>%
  summarise(records = sum(occurrences), .groups = "drop") %>%
  arrange(desc(records)) %>%
  slice_head(n = 10)

fig2 <- ggplot(top10,
               aes(reorder(publisher, records), records)) +
  geom_col(fill = "#005957") +
  geom_text(
    aes(label = scales::comma(records)),
    hjust = -0.1,
    size = 4.5
  ) +
  coord_flip() +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.1))
  ) +
  labs(
    x = "",
    y = "Number of occurrences",
    title = "Total occurrences per publisher since 2000"
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15),
    axis.title = element_text(size = 16, face = "bold"),
    plot.title = element_text(size = 16, face = "bold")
  )

fig2

publisher_ts <- total %>%
  filter(year >= 2000,
         publisher %in% top10$publisher) %>%
  group_by(year, publisher) %>%
  summarise(records = sum(occurrences), .groups = "drop")

n <- n_distinct(publisher_ts$publisher)

# B-Cubed gradient palette
gradient_palette <- colorRampPalette(c(
  "#6B3F2A",
  "#FFFFFF",
  "#005957",
  "#6CDDB4",
  "#48A529",
  "#000000"
))(n)

fig3 <- ggplot(publisher_ts,
               aes(year, records, fill = publisher)) +
  geom_col() +
  scale_fill_manual(values = gradient_palette) +
  labs(
    x = "Year",
    y = "Number of occurrences",
    fill = "Publisher",
    title = "Records per top 10 publisher since 2000"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    axis.title = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 10, face = "bold"),
    legend.position = "right"
  )

fig3

# Top 10 kingdoms bepalen
top10_kingdoms <- data_total_1km %>%
  filter(year >= 1975) %>%
  group_by(kingdom) %>%
  summarise(total_records = sum(occurrences), .groups = "drop") %>%
  arrange(desc(total_records)) %>%
  slice_head(n = 10) %>%
  pull(kingdom)

# Tijdreeks enkel voor top 10 kingdoms
kingdom_ts <- data_total_1km %>%
  filter(year >= 1975,
         kingdom %in% top10_kingdoms) %>%
  group_by(year, kingdom) %>%
  summarise(records = sum(occurrences), .groups = "drop")


# kleuren
n <- n_distinct(kingdom_ts$kingdom)

gradient_palette <- colorRampPalette(c(
  "#6B3F2A",
  "#FFFFFF",
  "#005957",
  "#6CDDB4",
  "#48A529",
  "#000000"
))(n)

# figuur
fig4 <- ggplot(kingdom_ts,
               aes(year, records, fill = kingdom)) +
  geom_col() +
  scale_fill_manual(values = gradient_palette) +
  labs(
    x = "Year",
    y = "Number of occurrences",
    fill = "Kingdom"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    axis.title = element_text(size = 10, face = "bold"),
    plot.title = element_text(size = 10, face = "bold"),
    legend.position = "right"
  )

fig4


map_data <- total %>%
  group_by(eeacellcode) %>%
  summarise(records = sum(occurrences), .groups = "drop")

map_sf <- FLANDERS_EEA_1km %>%
  left_join(map_data, by = c('CELLCODE'= "eeacellcode"))

fig5 <- ggplot(map_sf) +
  geom_sf(aes(fill = log10(records + 1)), colour = NA) +
  scale_fill_viridis_c(
    option = "D",
    direction = 1,
    name = "Number of records",
    breaks = c(1, 2, 3, 4, 5),
    labels = c('10', '100', '1000', "10000", "100000")
  ) +
  theme_void() +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold")
  )

fig5

fig5
