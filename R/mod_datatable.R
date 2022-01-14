#' datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_datatable_ui <- function(id){
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("dt"))
  )
}

#' datatable Server Functions
#'
#' @noRd
mod_datatable_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$dt <- DT::renderDT({
      shinipsum::random_DT(10, 5)
    })

  })
}

## To be copied in the UI
# mod_datatable_ui("datatable_ui_1")

## To be copied in the server
# mod_datatable_server("datatable_ui_1")
