# prep ----

library(tidyverse)
library(sf)

# geographic data ----

geos <- c("assembly", "borough", "commBoard", "congressional", "council", "modzcta",
          "nCode", "school", "stateSenate", "tract_2020", "tract_2010")

data <- list()
for (i in geos) {
  df <- st_read(paste0("data-raw/geo_", i, ".geojson")) %>%
    mutate(GEO_ID = as.character(GEO_ID))

  data[[paste0("geo_", i)]] <- df
}
list2env(data, envir=.GlobalEnv)
rm(data, df, i, geos)

crosswalk_tract_2020 <- read_csv("data-raw/crosswalk_tract_2020.csv") %>%
  mutate(across(where(is.numeric), as.character))

usethis::use_data(crosswalk_tract_2020, geo_assembly, geo_borough, geo_commBoard, geo_congressional, geo_council, geo_modzcta,
                  geo_nCode, geo_school, geo_stateSenate, geo_tract_2020, geo_tract_2010, overwrite = TRUE)

# response rate data ----

geos <- c("assembly", "borough", "commBoard", "congressional", "council", "modzcta",
          "nCode", "nyc", "school", "stateSenate", "tract_2020", "us")

data <- list()
for (i in geos) {
  df <- read_csv(paste0("data-raw/rr_", i, ".csv")) %>%
    mutate(GEO_ID = as.character(GEO_ID))

  if (i != "us") {
    df <- mutate(df, RESP_DATE = as.Date(RESP_DATE, format = "%m/%d/%Y"))
  }

  if (i %in% c("nyc", "us")) {
    df <- select(df, -GEO_ID)
  }

  if (i == "tract_2020") {
    df <- mutate(df, TRACT = as.character(TRACT))
  }

  data[[paste0("rr_", i)]] <- df
}
list2env(data, envir=.GlobalEnv)
rm(data, df, i, geos)

usethis::use_data(rr_assembly, rr_borough, rr_commBoard, rr_congressional, rr_council, rr_modzcta,
                  rr_nCode, rr_nyc, rr_school, rr_stateSenate, rr_tract_2020, rr_us, overwrite = TRUE)

