############################
# Read in packages and files
############################

library(readr)
library(sf)
library(dplyr)
library(ggplot2)
library(grDevices)


pd_cube_flanders_1km <- read_csv("./_preprocessing/data/interim/pd_indicator/pd_cube_flanders_1km.csv")
pd_cube_flanders_5km <- read_csv("./_preprocessing/data/interim/pd_indicator/pd_cube_flanders_5km.csv")

pd_cube_nonthreatened_1km <- read_csv("./_preprocessing/data/interim/pd_indicator/pd_cube_Flanders_1km_nonthreatened.csv")
pd_cube_nonthreatened_5km <- read_csv("./_preprocessing/data/interim/pd_indicator/pd_cube_Flanders_5km_nonthreatened.csv")

##########################
# calculate pd loss cube
##########################
pd_loss_cube_1km <- left_join(pd_cube_flanders_1km, pd_cube_nonthreatened_1km, by = "eeacellcode")
pd_loss_cube_5km <- left_join(pd_cube_flanders_5km, pd_cube_nonthreatened_5km, by = "eeacellcode")

pd_loss_cube_1km <- pd_loss_cube_1km %>% mutate(pd_loss= pd.x - pd.y)
pd_loss_cube_5km <- pd_loss_cube_5km %>% mutate(pd_loss= pd.x - pd.y)


pd_loss_cube_1km<-pd_loss_cube_1km%>%
  select(eeacellcode, pd_loss)
pd_loss_cube_5km<-pd_loss_cube_5km%>%
  select(eeacellcode, pd_loss)

write.csv(pd_loss_cube_1km, './_preprocessing/data/interim/pd_indicator/pd_loss_cube_1km.csv')
write.csv(pd_loss_cube_5km, './_preprocessing/data/interim/pd_indicator/pd_loss_cube_5km.csv')
