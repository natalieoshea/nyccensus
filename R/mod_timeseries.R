#' timeseries UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import ggplot2
mod_timeseries_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(ns("timeseries"), height = 350, width = 420)
  )
}

#' timeseries Server Functions
#'
#' @noRd
mod_timeseries_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # create graph of daily change over time
    output$timeseries <- renderPlot({
      time_data <- rr_data[["nyc"]] %>%
        select(RESP_DATE, DRRALL) %>%
        mutate(RESP_DATE = as.Date(RESP_DATE))

      max_date <- time_data %>%
        filter(DRRALL == max(DRRALL))

      ggplot(time_data, aes(x=RESP_DATE, y=DRRALL)) +
        geom_line(color = viridis::viridis(1, begin = 0.2, end = 0.6)) +
        geom_point(color = viridis::viridis(1, begin = 0.2, end = 0.6), size = 1) +
        scale_y_continuous(labels = scales::percent_format(scale = 1)) +
        labs(title = "2020 Census Daily Response Rate",
             subtitle = paste0("Max Daily Response Rate: ", max_date$DRRALL, "% (", max_date$RESP_DATE, ")"),
             caption = paste0("Data as of ", max(time_data$RESP_DATE), "; USCB-reported daily response rate (all)")) +
        theme_census() +
        theme(axis.title.x = element_blank(),
              axis.title.y = element_blank())
    })

  })
}

## To be copied in the UI
# mod_timeseries_ui("timeseries_ui_1")

## To be copied in the server
# mod_timeseries_server("timeseries_ui_1")
