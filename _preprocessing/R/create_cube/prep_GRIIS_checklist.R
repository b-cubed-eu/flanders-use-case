GRIIS_Flanders <- distribution%>%
  filter(locality=="Flemish Region")

GRIIS_Flanders$speciesid <- sub(".*species/", "", GRIIS_Flanders$id)

write.csv(GRIIS_Flanders, './_preprocessing/data/raw/GRIIS_Flanders.csv')
