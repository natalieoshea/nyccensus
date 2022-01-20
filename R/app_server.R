#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {

  # Map ----
  mod_var_server("var_ui_1")
  mod_geo_server("geo_ui_1")
  mod_date_server("date_ui_1")
  mod_map_server("map_ui_1")

  # Data Explorer ----
  mod_geo_server("geo_ui_2")
  mod_dateRange_server("dateRange_ui_1")
  mod_boro_server("boro_ui_1")
  mod_datatable_server("datatable_ui_1")

}
