#' demographics UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import ggplot2 dplyr
mod_demographics_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(ns("demographics"), height = 350, width = 420)
  )
}

#' demographics Server Functions
#'
#' @noRd
mod_demographics_server <- function(id, geo, r6){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observeEvent(gargoyle::watch("update_selection"), {
      output$demographics <- renderPlot({
        plot_demographics(ClickedShapeR6$demo_data)
      })
    })

  })
}

## To be copied in the UI
# mod_demographics_ui("demographics_ui_1")

## To be copied in the server
# mod_demographics_server("demographics_ui_1")
