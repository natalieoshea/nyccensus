# response rate data ----------------------------

library(tidyverse)

geos <- c("assembly", "borough", "commBoard", "congressional", "council", "modzcta",
          "nCode", "nyc", "school", "stateSenate", "tract_2020", "us")

data <- list()
for (i in geos) {
  df <- read_csv(paste0("data-raw/rr_", i, ".csv")) %>%
    mutate(GEO_ID = as.character(GEO_ID))

  if (i != "us") {
    df <- mutate(df, RESP_DATE = as.Date("RESP_DATE", format = "%m/%d/%Y"))
  }

  if (i %in% c("nyc", "us")) {
    df <- select(df, -GEO_ID)
  }

  if (i == "tract_2020") {
    df <- mutate(df, TRACT = as.character(TRACT))
  }

  data[[i]] <- df
}
list2env(data, envir=.GlobalEnv)
rm(data, df, geos, i)

usethis::use_data(assembly, borough, commBoard, congressional, council, modzcta,
                  nCode, nyc, school, stateSenate, tract_2020, us, overwrite = TRUE)
