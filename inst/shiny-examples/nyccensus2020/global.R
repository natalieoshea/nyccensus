# load libraries ----
library(tidyverse)
library(shiny)
library(sf)
library(leaflet)
library(shinyjs)
library(RMySQL)
library(rjson)
library(basemapR)
library(RColorBrewer)

# load data ----

# load srr data
rr_tract_2020 <- nyccensus::rr_tract_2020
rr_nCode <- nyccensus::rr_nCode
rr_assembly <- nyccensus::rr_assembly
rr_borough <- nyccensus::rr_borough
rr_commBoard <- nyccensus::rr_commBoard
rr_congressional <- nyccensus::rr_congressional
rr_council <- nyccensus::rr_council
rr_school <- nyccensus::rr_school
rr_stateSenate <- nyccensus::rr_stateSenate
rr_modzcta <- nyccensus::rr_modzcta
rr_nyc <-nyccensus::rr_nyc
rr_us <- nyccensus::rr_us

# load shapefiles
geo_tract_2020 <- nyccensus::geo_tract_2020
geo_nCode <- nyccensus::geo_nCode
geo_assembly <- nyccensus::geo_assembly
geo_borough <- nyccensus::geo_borough
geo_commBoard <- nyccensus::rr_commBoard
geo_congressional <- nyccensus::geo_congressional
geo_council <- nyccensus::geo_council
geo_school <- nyccensus::geo_school
geo_stateSenate <- nyccensus::geo_stateSenate
geo_modzcta <- nyccensus::geo_modzcta

# load crosswalk file
crosswalk_tract_2020 <- nyccensus::crosswalk_tract_2020

# transform data ----

# set park-cemetery tracts and tracts with no response rate data to NA
rr_tract_2020 <- rr_tract_2020 %>%
  mutate(across(where(is.numeric), ~ifelse(str_detect(NEIGHBORHOOD, "park-cemetery"), NA, .)),
         across(where(is.numeric), ~ifelse(TRACT %in% c("5303","104","500"), NA, .)))

rr_nCode <- rr_nCode %>%
  mutate(across(where(is.numeric), ~ifelse(str_detect(NEIGHBORHOOD, "park-cemetery"), NA, .)))

# save census variables
census_vars <- c("Cumulative Response Rate" = "CRRALL",
                 "Cumulative Response Rate (Internet)" = "CRRINT",
                 "Daily Response Rate" = "DRRALL",
                 "Daily Response Rate (Internet)" = "DRRINT")

# save census geos
census_geos <- c("Neighborhood" = "nCode",
                 "Census Tract" = "tract_2020",
                 "Borough" = "borough",
                 "Congressional District" = "congressional",
                 "State Senate District" = "stateSenate",
                 "City Council District" = "council",
                 "Assembly District" = "assembly",
                 "School District" = "school",
                 "Community Board District" = "commBoard",
                 "Zip Code" = "modzcta")

