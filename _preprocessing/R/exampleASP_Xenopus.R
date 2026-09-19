library(ggplot2)

`apply_gam_data.(2)` <- read.csv2("C:/Users/jasmijn_hillaert/Downloads/apply_gam_data (2).csv")
View(`apply_gam_data.(2)`)
test <- `apply_gam_data.(2)


ggplot(test, aes(x = Year, y = Occupancy)) +
  
  # Schaduw tussen lcl en ucl
  geom_ribbon(aes(ymin = lcl, ymax = ucl),
              alpha = 0.2) +
  
  # Trendlijn
  geom_line(linewidth = 1) +
  
  # Punten gekleurd volgens emerging.status
  geom_point(aes(colour = emerging.status),
             size = 3) +
  
  labs(
    x = "Year",
    y = "Occupancy",
    colour = "Emerging status",
    title = expression("Occupancy GAM - " * italic("Xenopus laevis")))+

  
  theme_minimal()
