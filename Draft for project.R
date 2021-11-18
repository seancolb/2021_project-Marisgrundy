library(spData)
library(sf)
library(units)
library(ggplot2)
library(viridis)
library(broom)
library(dplyr)
library(tidycensus)
library(choroplethr)
library(choroplethrMaps)
library(raster)
library(rasterVis)
library(tidyverse)
library(ggpmisc)
library(lwgeom)

#load population data
#first you need a Census key

#census_api_key("d7a2cd0f27c540f5b9cef151c8472838c33d797f", overwrite= TRUE, install= TRUE)

#identify variables for consideration
v1 <- load_variables(2019, "acs1", cache=TRUE)
#View(v1)

# crop to domain (Erie County, tract level)
census_data<- get_acs(geography="tract",
              variables= "B07011_001",
              year=2019,
              state="NY",
              county = "Erie",
              geometry= TRUE)

#census_data

ggplot(census_data)+
  geom_sf()

# define census region using a spatial bounding box and rasterize data
bbox<-st_bbox(census_data)
domain <- raster(resolution=0.008,crs=projection(census_data),
                 xmn=bbox$xmin,xmx=bbox$xmax,ymn=bbox$ymin,ymx=bbox$ymax)


#load watershed data and bind watersheds of interest into one raster
require(sf)
wetlands <- bind_rows(
  read_sf(dsn = "Data/HU8_04120103_Watershed_erie/HU8_04120103_Wetlands.shp"),
  read_sf(dsn = "Data/HU8_04120104_Watershed_niagara/HU8_04120104_Wetlands.shp")
)%>%
  st_transform(projection(census_data))


wetlands_raster=rasterize(as(wetlands,"Spatial"),domain,field=1)
wetlands_distance=distance(wetlands_raster)

plot(wetlands_raster, main= 'Wetlands in Erie County', xlab='Longitude', ylab='Latitude')
plot(wetlands_distance, main='Proximity to wetlands in Erie County', xlab='Longitude', ylab='Latitude',asp=1)


#Here's a histogram of the distribution of wetlands in Erie County by Distance
#This shows us how frequently a specific distance to any wetland occurs
dist_wetland <- hist(wetlands_distance, breaks=10, main='Distribution of Wetlands by Distance', xlab='Distance in Meters', col="chartreuse4")
dist_wetland$counts

#Now 
#breaking apart wetland vector by census tract
sf::sf_use_s2(FALSE)
wetlands_intersected<-wetlands %>% 
  st_intersection(census_data)%>%
  group_by(GEOID)%>%
  summarize(wetland_area=sum(st_area(geometry)),wetland_count=n())%>%
  st_set_geometry(NULL)

#Select only GEOID, wetland_area, wetland_count
select(wetlands_intersected, "GEOID", "wetland_area", "wetland_count")
  
#left_join wetlands intersected with census data(L) by GEOID
major_table<- left_join(census_data, wetlands_intersected)

#RIGHT HERE!!!!!
#compare column titles I care about
plot1<-ggplot(major_table, aes(estimate, as.numeric(wetland_area)))+
  geom_point(colour='green4')+
  geom_smooth()

plot1 + labs("Median Income vs Wetland Area",
  x="Median Income", y="Wetland Area")

#mean distance with income
census_data$meandist<- raster::extract(wetlands_distance, census_data, fun=mean)

plot2<- ggplot(census_data, aes(fill= meandist))+
  geom_sf()
plot2


#median distance with income
census_data$mediandist<- raster::extract(wetlands_distance, census_data, fun=median)

plot3<- ggplot(census_data, aes(fill= mediandist))+
  geom_sf()
plot3


##HEREEEEEEEEE
#Attempt at choropleth and bubble
ggplot(census_data, aes(x=GEOID, y=meandist))+
  geom_sf()+
  geom_point(data=major_table, mapping=aes(x=GEOID, y=estimate))+
  scale_color_viridis()


#The final figure I would like to create isn't working, but I am attempting to create
#a choropleth map filled with mean distance to wetland overlaid with a bubble map showing 
#estimated income in census tract.  If you have suggestions please help!  This is attempt
#one million.
census_data$estimate %>%
  ggplot() +
  geom_sf(major_table, aes(geometry=geometry), fill='#d5d5d2', colour=NA) +
  geom_point(aes(x=longitude, y=latitude, size=estimate, color=estimate, alpha=estimate),
             shape=20, stroke=FALSE) +
  scale_color_viridis(option="magma", trans="log",
                      name='Income ($)') +
  theme_void() + coord_sf()
