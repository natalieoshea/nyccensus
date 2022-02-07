#' timeseries UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_timeseries_ui <- function(id){
  ns <- NS(id)
  tagList(
    dygraphs::dygraphOutput(ns("timeseries"))
  )
}

#' timeseries Server Functions
#'
#' @noRd
mod_timeseries_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # create dygraph of daily change over time
    output$timeseries <- dygraphs::renderDygraph({
      time_data <- rr_data[["nyc"]] %>%
        dplyr::select(RESP_DATE, DRRALL)

      time_data <- xts::xts(x = time_data$DRRALL, order.by = time_data$RESP_DATE)

      dygraphs::dygraph(time_data, ylab = "Daily Change (%)") %>%
        dygraphs::dySeries("V1", label = "Daily Change") %>%
        dygraphs::dyOptions(fillGraph = TRUE, drawGrid = FALSE)
    })

  })
}

## To be copied in the UI
# mod_timeseries_ui("timeseries_ui_1")

## To be copied in the server
# mod_timeseries_server("timeseries_ui_1")
