# geojson data ----

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC assembly districts
#'
#' @format A sf data frame with 65 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{assembly district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_assembly"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC boroughs
#'
#' @format A sf data frame with 5 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{borough}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_borough"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC community board districts
#'
#' @format A sf data frame with 71 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{community board district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_commBoard"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC congressional districts
#'
#' @format A sf data frame with 13 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{congressional district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_congressional"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC council districts
#'
#' @format A sf data frame with 51 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{council district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_council"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC zip codes (modified zip code
#'  tabulation areas)
#'
#' @format A sf data frame with 178 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{modzcta (modified zip code tabulation area)}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_modzcta"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC neighborhoods
#'
#' @format A sf data frame with 253 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{neighborhood code (nCode)}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_nCode"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC school districts
#'
#' @format A sf data frame with 32 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{school district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_school"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC state senate districts
#'
#' @format A sf data frame with 26 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{state senate district}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_stateSenate"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC census tracts (2010 geography)
#'
#' @format A sf data frame with 2197 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{census tract (2010 geography)}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_tract_2010"

#' Geographic Shapefile for NYC
#'
#' A dataset containing a simple features (sf) data frame of NYC census tracts (2020 geography)
#'
#' @format A sf data frame with 2197 rows and 2 variables
#' \describe{
#'   \item{GEO_ID}{census tract (2020 geography)}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_tract_2020"

# census 2020 data ----

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC assembly districts.
#'  The variables are as follows:
#'
#' @format A data frame with 11,115 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{assembly district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_assembly"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC boroughs.
#'  The variables are as follows:
#'
#' @format A data frame with 855 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{borough}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_borough"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC community board districts.
#'  The variables are as follows:
#'
#' @format A data frame with 10,089 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{community board district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_commBoard"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC congressional districts.
#'  The variables are as follows:
#'
#' @format A data frame with 2,223 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{congressional district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_congressional"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC council districts.
#'  The variables are as follows:
#'
#' @format A data frame with 8,721 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{council district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_council"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC zip codes (modified zip code.
#'  tabulation areas). The variables are as follows:
#'
#' @format A data frame with 30,096 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{modzcta district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_modzcta"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC neighborhoods.
#'  The variables are as follows:
#'
#' @format A data frame with 42,750 rows and 8 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{neighborhood code (nCode)}
#'   \item{BORO}{borough}
#'   \item{NEIGHBORHOOD}{neighborhood}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_nCode"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for NYC.
#'  The variables are as follows:
#'
#' @format A data frame with 171 rows and 5 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_nyc"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census in NYC school districts.
#'  The variables are as follows:
#'
#' @format A data frame with 5,472 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{school district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_school"

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census in NYC state senate districts.
#'  The variables are as follows:
#'
#' @format A data frame with 4,446 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{state senate district}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_stateSenate"


#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census in NYC census tracts (2020 geography).
#'  The variables are as follows:
#'
#' @format A data frame with 383,541 rows and 9 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{census tract (2020 geography)}
#'   \item{BORO}{borough}
#'   \item{NEIGHBORHOOD}{neighborhood}
#'   \item{TRACT}{tract}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_tract_2020"

#' Daily Response Rate Data for the 2020 Census in the United States
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for the US.
#'  The variables are as follows:
#'
#' @format A data frame with 11,115 rows and 6 variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_us"
