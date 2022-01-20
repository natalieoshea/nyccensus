#' geo UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_geo_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectInput(ns("geo"), "Geography", c("Neighborhood" = "nCode",
                                          "Census Tract" = "tract_2020",
                                          "Borough" = "borough",
                                          "Congressional District" = "congressional",
                                          "State Senate District" = "stateSenate",
                                          "City Council District" = "council",
                                          "Assembly District" = "assembly",
                                          "School District" = "school",
                                          "Community Board District" = "commBoard",
                                          "Zip Code" = "modzcta"))
  )
}

#' geo Server Functions
#'
#' @noRd
mod_geo_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    return(
      reactive({
        input$geo
      })
    )

  })
}

## To be copied in the UI
# mod_geo_ui("geo_ui_1")

## To be copied in the server
# mod_geo_server("geo_ui_1")
