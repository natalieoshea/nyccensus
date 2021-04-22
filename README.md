# nyccensus

The `nyccensus` package is a simple data-sharing package meant to ease the pains of accessing and wrangling publicly-available response rate data from the 2020 Decennial Census as well as other relevant demographic data from the American Community Survey at various geographic levels in New York City

# Installation

You can install the current version of nyccensus from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("natalieoshea/nyccensus")
```
# Example: run shiny examples

``` r
# nyccensus2020 map
nyccensus::runExample("nyccensus2020")

# bivariate maps
nyccensus::runExample("bivariate_maps")
```
# Example: bivariate map

``` r
# install.packages("devtools", "tidyverse", "sf", "biscale")
# install_github('Chrisjb/basemapR')

# load libraries
library(tidyverse)
library(sf)
library(biscale)
library(basemapR)

# load data
map <- nyccensus::geo_nCode
df <- nyccensus::demos_nCode

# calculate bi-classes
df_bi <- bi_class(df, x = Language_LimitedEnglish_Total, y = HealthInsurance_NotCovered) %>%
  mutate(bi_class = ifelse(str_detect(bi_class, "NA"), NA, bi_class)) %>%
  select(GEO_ID, Language_LimitedEnglish_Total, HealthInsurance_NotCovered, bi_class)

# join data
map_df <- map %>%
  left_join(df_bi)

# map
ggplot() +
  base_map(st_bbox(map_df), basemap = "dark", increase_zoom = 2, nolabels = TRUE) +
  geom_sf(data = map_df, aes(fill = bi_class), color = "lightgrey",
          size = 0.1, show.legend = FALSE) +
  bi_scale_fill(pal = "DkBlue", dim = 3) +
  theme(axis.line = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        panel.grid = element_blank(),
        panel.border = element_blank())
```

![bivariate map of New York City neighborhoods](https://github.com/natalieoshea/nyccensus/blob/master/man/figures/bivariate_map.png?raw=true)

``` r
# bivariate legend
bi_legend(pal = "DkBlue", dim = 3, size = 16,
          xlab = "Limited English (%)",
          ylab = "No Health Insurance (%)")

```

![bivariate map legend](https://github.com/natalieoshea/nyccensus/blob/master/man/figures/bivariate_legend.png?raw=true)
