#' boro UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_boro_ui <- function(id){
  ns <- NS(id)
  tagList(
    selectInput("boro", "Borough",
                c("All boroughs" = "", c("Bronx","Brooklyn","Manhattan","Queens","Staten Island")),
                multiple = TRUE)
  )
}

#' boro Server Functions
#'
#' @noRd
mod_boro_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    return(
      reactive({
        input$boro
      })
    )

  })
}

## To be copied in the UI
# mod_boro_ui("boro_ui_1")

## To be copied in the server
# mod_boro_server("boro_ui_1")
