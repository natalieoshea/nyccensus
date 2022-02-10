#' date UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_date_ui <- function(id){
  ns <- NS(id)
  tagList(
    uiOutput(ns("date"))
  )
}

#' date Server Functions
#'
#' @noRd
mod_date_server <- function(id, var){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$date <- renderUI({
      if (var() == "Change Between Dates") {
        dateRangeInput(ns("date"), "Response Dates",
                       start = as.Date("2020-03-20"), end = as.Date("2020-10-17"),
                       min = as.Date("2020-03-20"), max = as.Date("2020-10-17"))
      } else {
        dateInput(ns("date"), "Response Date",
                  value = as.Date("2020-10-17"),
                  min = as.Date("2020-03-20"),
                  max = as.Date("2020-10-17")
        )
      }
    })

    return(
      reactive({
        input$date
      })
    )

  })
}

## To be copied in the UI
# mod_date_ui("date_ui_1")

## To be copied in the server
# mod_date_server("date_ui_1")
