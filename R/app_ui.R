#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # add external resources
    golem_add_external_resources(),
    # app UI logic
    navbarPage("NYC Census 2020",
               id = "nav",

               # Map ----
               tabPanel("Map",
                        div(
                          class = "outer",
                          mod_map_ui("map_map"),
                          absolutePanel(
                            id = "controls", class = "panel panel-default",
                            top = 70, left = 20, width = 460, fixed=TRUE,
                            draggable = FALSE, height = "auto",

                            h4("Response Rates"),
                            mod_var_ui("var_map"),
                            mod_geo_ui("geo_map"),
                            mod_date_ui("date_map"),

                            hr(),

                            tabsetPanel(
                              tabPanel("Overview"),
                              tabPanel("Time Series",
                                       mod_timeseries_ui("timeseries_ui_1")),
                              tabPanel("Languages"),
                              tabPanel("Demographics",
                                       mod_demographics_ui("demographics_ui_1"))
                            )

                          )
                        )
               ),

               # Data Explorer ----
               tabPanel("Data Explorer",
                        fluidRow(
                          column(3, mod_geo_ui("geo_data")),
                          column(3, mod_dateRange_ui("dateRange_data")),
                          column(3, mod_boro_ui("boro_data"))
                        ),
                        hr(),
                        mod_datatable_ui("datatable_data")
                        ),
               tabPanel("Borough Overview")
               )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){

  add_resource_path(
    'www', app_sys('app/www')
  )

  tags$head(
    favicon(ext = 'png'),
    # add link to CSS style sheet
    tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css"),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'nyccensus'
    )
  )

}

