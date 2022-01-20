#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    # fluidPage(
    #   h1("A Data Table"),
    #   mod_datatable_ui("datatable_ui_1")
    # )
    navbarPage("NYC Census 2020",
               id = "nav",
               tabPanel("Map",
                        div(
                          #tags$head(includeCSS("inst/app/www/custom.css")),
                          # tags$link(rel = "stylesheet",
                          #           type = "text/css",
                          #           href = "www/custom.css"),
                          class = "outer",
                          mod_map_ui("map_ui_1")
                          )
                        ),
               tabPanel("Data Explorer",
                        h1("A Data Table"),
                        mod_datatable_ui("datatable_ui_1")
                        )
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

