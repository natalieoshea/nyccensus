#' dateRange UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_dateRange_ui <- function(id){
  ns <- NS(id)
  tagList(
    dateRangeInput(ns("dateRange"), "Response Date",
                   start = as.Date("2020-03-20"), end = as.Date("2020-10-17"),
                   min = as.Date("2020-03-20"), max = as.Date("2020-10-17"))
  )
}

#' dateRange Server Functions
#'
#' @noRd
mod_dateRange_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    return(
      reactive({
        input$dateRange
      })
    )

  })
}

## To be copied in the UI
# mod_dateRange_ui("dateRange_ui_1")

## To be copied in the server
# mod_dateRange_server("dateRange_ui_1")
