Project Proposal
================
Maris Grundy
10/13/2021

## Introduction

Urbanization is one of the largest drivers of ecosystem degradation due
to land use change and habitat fragmentation from agriculture, housing,
and infrastructure development (McCauley et al. 2013). The impacts of
ecosystem loss to urbanization are not reflected equally within society.
Instead, these losses reflect larger societal inequalities present in
cities (Schell et al. 2020). This project will look at spatial
distribution of instact wetlands in Erie County as it relates to mean
household income.

### Hypothesis

I hypothesize that areas of lower mean household income will be
geographically farther from intact wetlands in Erie County.

------------------------------------------------------------------------

## Inspiring Examples

Here are some examples of graphics I would like to create:
<center>

![Choropleth
Map](https://www.r-graph-gallery.com/327-chloropleth-map-from-geojson-with-ggplot2_files/figure-html/thecode9-1.png)

</center>
<center>

![Bubble
Map](https://www.r-graph-gallery.com/330-bubble-map-with-ggplot2_files/figure-html/thecode5-1.png)

</center>
<center>
![Choropleth and Bubble
Map](https://www.researchgate.net/publication/324652152/figure/fig1/AS:617480074584064@1524230130529/World-map-created-with-package-tmap-The-bottom-layer-is-a-choropleth-of-income-class-on.png "fig:")
</center>
<center>

![Another example of both
together](https://www.anychart.com/blog/wp-content/uploads/2020/05/js-choropleth-map-customized-final.png)

</center>
<center>

![Scatterplot](https://www.marsja.se/wp-content/uploads/2019/10/scatterplot_in_R_with_ggplot2_correlation.png)

</center>

------------------------------------------------------------------------

## Proposed Data Sources

My proposed data sources are: [National Wetlands
Inventory](https://www.fws.gov/wetlands/data/Mapper.html) and [Census
Data](https://data.census.gov/cedsci/)

------------------------------------------------------------------------

## Proposed Methods

``` r
library(spData)
library(sf)
library(tidyverse)
library(units)
library(ggplot2)
library(viridis)
library(broom)
library(dplyr)
```

**All code shown below is to demonstrate something similar to what the
final code will be-not a representation of the actual code!**

**Also, I need to figure out how the data will need to be prepped, but
you’ll get the idea…**

### 1. Choropleth map with a bubble map

*choropleth* I plan to create a choropleth map that shows how many
wetlands are in each census tract so I will need: - A geospatial object
providing region boundaries= from census data - A numeric variable to
color each geographical unit= wetland mapper (fill=value)

*bubble* On top of the choropleth map from above, I plan to overlay a
static bubble map showing mean household income

*To create the choropleth/bubble*

``` r
#I know there is some spatial join that will need to occur first!

#then I will fortify geospatial data
library(broom)
  tidy_data<-(tidy(geospatial, region="wetland"))

#then I will plot numeric variable (number of wetlands) onto geospatial object (choropleth map)
  #I plan to play with themes more when I make this
ggplot() +
  geom_polygon(data = tidy_data, aes( x = long, y = lat, group=group, fill=value)) +
  scale_fill_gradient(high = "#e34a33", low = "#fee8c8", guide = "colorbar")+
  theme_void() +
  coord_map() +
    guides(fill=guide_colorbar(title="HP Index"))+
    theme(legend.justification=c(0,0), legend.position=c(0,0))

#then to add the bubble
 arrange(mean_income) %>% 
 mutate( name=factor(name, unique(name))) %>% 
 ggplot() +
    geom_polygon(data = mean_income, aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
    geom_point( aes(x=long, y=lat, size=pop, color=pop), alpha=0.9) +
    scale_size_continuous(range=c(1,12)) +
    scale_color_viridis(trans="log") +
    theme_void() + ylim(50,59) + coord_map()
```

[Inspiration for the above code](www.r-graph-gallery.com)

### 2. Scatterplot

I will also create a scatterplot that shows possible correlation between
2 relevant numerical values (x= mean household income in tract, y=number
of wetlands in tract)

*To create the scatterplot*

``` r
ggplot(data_source, aes(x=mean_income, y=num_wetlands))+
geom_point()+
  geom_smooth
```

------------------------------------------------------------------------

## Expected Results

1.  A graphic (bubble and choropleth map) that displays wetland extent
    and mean income for census tracts in Erie County.

2.  A graphic (scatterplot) that shows possible correlation between mean
    household income in 2019 and number of wetlands present within each
    census tract.
