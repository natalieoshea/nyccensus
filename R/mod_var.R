#' var UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_var_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectInput(ns("var"), "Variable", c("Cumulative Response Rate",
                                         "Change Between Dates"))
  )
}

#' var Server Functions
#'
#' @noRd
mod_var_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    return(
      reactive({
        input$var
      })
    )

  })
}

## To be copied in the UI
# mod_var_ui("var_ui_1")

## To be copied in the server
# mod_var_server("var_ui_1")
