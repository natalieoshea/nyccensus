#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session, global ) {

  # Map ----
  var_map <- mod_var_server("var_map")
  geo_map <- mod_geo_server("geo_map")
  date_map <- mod_date_server("date_map", var_map)
  mod_map_server("map_map", var_map, geo_map, date_map)
  mod_overview_server("overview_map")
  mod_timeseries_server("timeseries_map")
  mod_languages_server("languages_map")
  mod_demographics_server("demographics_map")

  # Data Explorer ----
  geo_data <- mod_geo_server("geo_data")
  dateRange_data <- mod_dateRange_server("dateRange_data")
  boro_data <- mod_boro_server("boro_data")
  mod_datatable_server("datatable_data", geo_data, dateRange_data, boro_data)

}
