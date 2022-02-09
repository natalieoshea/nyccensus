#' overview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import ggplot2
mod_overview_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(ns("overview"))
  )
}

#' overview Server Functions
#'
#' @noRd
mod_overview_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$overview <- renderPlot({
      bin_width <- 5

      us <- rr_data[["us"]] %>%
        filter(RESP_DATE == max(RESP_DATE)) %>%
        pull(CRRALL)

      nyc <- rr_data[["nyc"]] %>%
        filter(RESP_DATE == max(RESP_DATE)) %>%
        mutate(group = cut(CRRALL, seq(0, 100, by = bin_width), labels = FALSE, include.lowest = TRUE),
               difference = CRRALL - us,
               type = case_when(
                 difference > 0 ~ "above",
                 difference == 0 ~ "same",
                 difference < 0 ~ "below"
               ))

      histogram_data <- rr_data[["tract_2020"]] %>%
        filter(RESP_DATE == max(RESP_DATE)) %>%
        mutate(group = cut(CRRALL, seq(0, 100, by = bin_width), labels = FALSE, include.lowest = TRUE),
               highlight = if_else(group == nyc$group, "A", "B"))

      summary_data <- histogram_data %>%
        summarize(above = ((sum(CRRALL > nyc$CRRALL, na.rm = T)) / n()) * 100,
                  below = ((sum(CRRALL <= nyc$CRRALL, na.rm = T)) / n()) * 100) %>%
        mutate(across(everything(), ~round(., digits = 1)))

      ggplot2::ggplot(histogram_data, aes(x = CRRALL, alpha = highlight)) +
        geom_histogram(boundary = 0, binwidth = bin_width,
                       fill = viridis::viridis(1, begin = 0.2, end = 0.6)) +
        geom_vline(xintercept = nyc$CRRALL, size = 1,
                   color = "grey80") +
        scale_x_continuous(labels = scales::percent_format(scale = 1)) +
        scale_alpha_manual(values = c(1, 0.8), guide = "none") +
        labs(title = paste0(nyc$CRRALL, "% Cumulative Response Rate (",
                            if_else(nyc$type != "same",
                                    paste0(abs(nyc$difference), " points ", nyc$type, " the national)"),
                                    "Equal to the national)")),
             subtitle = paste0("Greater than ", summary_data$above, "% of all census tracts in New York City"),
             caption = paste0("Data as of ", nyc$RESP_DATE)) +
        theme_census() +
        theme(axis.title.x = element_blank(),
              axis.title.y = element_blank())
    })

  })
}

## To be copied in the UI
# mod_overview_ui("overview_ui_1")

## To be copied in the server
# mod_overview_server("overview_ui_1")
