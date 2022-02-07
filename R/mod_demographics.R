#' demographics UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_demographics_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(ns("demographics"))
  )
}

#' demographics Server Functions
#'
#' @noRd
mod_demographics_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

## To be copied in the UI
# mod_demographics_ui("demographics_ui_1")

## To be copied in the server
# mod_demographics_server("demographics_ui_1")
