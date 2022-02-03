# geographic data ----

#' Geographic Crosswalk for 2020 Census Tracts in NYC
#'
#' A dataset containing a crosswalk file listing the various geographies each
#'  2020 census tract is assigned to in New York City
#'
#' @format A data frame with 2,312 rows and 15 variables
#' \describe{
#'   \item{tract_2020}{full census tract id (2020 geography)}
#'   \item{GEOID10}{10-digit census tract id (2020 geography)}
#'   \item{tract}{census tract (2020 geography)}
#'   \item{tract_name}{census tract name (2020 geography)}
#'   \item{borough }{borough}
#'   \item{neighborhood}{neighborhood}
#'   \item{nCode}{unique neighborhood code}
#'   \item{congressional}{congressional district}
#'   \item{stateSenate}{state senate district}
#'   \item{council}{city council district}
#'   \item{assembly}{assembly district}
#'   \item{school}{school district}
#'   \item{commBoard}{community board district}
#'   \item{zip}{zip code}
#'   \item{modzcta}{modified zip code tabulation area}
#' }
"crosswalk_tract_2020"

#' Geographic Shapefiles for NYC
#'
#' A list containing a simple features (sf) data frame for each of the following NYC geographies:
#'  - assembly districts (assembly)
#'  - boroughs (borough)
#'  - community boards (commBoard)
#'  - congressional districts (congressional)
#'  - city council districts (council)
#'  - zip code (modzcta)
#'  - neighborhood (nCode)
#'  - school district (school)
#'  - state senate district (stateSenate)
#'  - census tracts (tract_2010 and tract_2020)
#'  - New York City (nyc)
#'  - Nationwide (us)
#'
#' @format A large list containing 11 elements representing different geographic levels. Each element contains a sf data frame with 2 variables:
#' \describe{
#'   \item{GEO_ID}{geographic identifier}
#'   \item{geometry}{multipolygon geometry}
#' }
"geo_data"

# response rate data ----

#' Daily Response Rate Data for the 2020 Census in New York City
#'
#' A dataset containing daily response rate data (March 20 to October 17) reported
#'  by the US Census Bureau for the 2020 Census for the following NYC geographies:
#'  - assembly districts (assembly)
#'  - boroughs (borough)
#'  - community boards (commBoard)
#'  - congressional districts (congressional)
#'  - city council districts (council)
#'  - zip code (modzcta)
#'  - neighborhood (nCode)
#'  - school district (school)
#'  - state senate district (stateSenate)
#'  - census tracts (tract_2020)
#'
#' @format A large list containing 10 elements representing different geographic levels. Each element contains the following variables:
#' \describe{
#'   \item{RESP_DATE}{response date (format: YYYY-MM-DD)}
#'   \item{GEO_ID}{geographic identifier}
#'   \item{CRRALL}{cumulative response rate}
#'   \item{CRRINT}{cumulative response rate (internet-only)}
#'   \item{DRRALL}{daily response rate}
#'   \item{DRRINT}{daily response rate (internet-only)}
#' }
"rr_data"

# acs data ----

#' American Community Survey Data for NYC Assembly Districts
#'
#' A dataset containing demographic data from the American Community Survey.
#'  Includes information on: total population, total housing units (rented vs. owned),
#'  median age, median income, sex, poverty, SNAP recipients, age, race, household
#'  type, marital status, education level, and language. All variables are from the
#'  2019 ACS 5-yr estimates except language data, which is only available below the
#'  county level through the 2015 ACS.
#'
#'  Data available for the following NYC geographies:
#'  - assembly districts (assembly)
#'  - boroughs (borough)
#'  - community boards (commBoard)
#'  - congressional districts (congressional)
#'  - city council districts (council)
#'  - zip code (modzcta)
#'  - neighborhood (nCode)
#'  - school district (school)
#'  - state senate district (stateSenate)
#'  - census tracts (tract_2010)
#'
#' @format A large list containing 10 elements representing different geographic levels. Each element contains a data frame with 162 demographic variables.
"demos_data"
