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
        # wrangle data
        plot_data <- ClickedShapeR6$demo_data %>%
          select(contains("Race_")) %>%
          pivot_longer(
            cols = everything(),
            names_to = c("group", "race", "ethnicity"),
            names_sep = "_",
            values_to = "percentage"
          ) %>%
          select(-group) %>%
          mutate(race = recode(race, "MoreThanOne" = "More than One",
                               "Amerind" = "Native American",
                               "Pacific" = "Pacific Islander"),
                 ethnicity = recode(ethnicity, "NotHispanic" = "Not Hispanic")) %>%
          # reverse factors
          mutate(race = forcats::fct_rev(race),
                 ethnicity = forcats::fct_rev(ethnicity))

        # save percent hispanic
        percent_hispanic <- plot_data %>%
          group_by(ethnicity) %>%
          summarize(total = sum(percentage)) %>%
          filter(ethnicity == "Hispanic") %>%
          mutate(total = round(total * 100, digits = 1)) %>%
          pull(total)

        # calculate totals for bar labels
        race_totals <- plot_data %>%
          group_by(race) %>%
          summarize(percentage = sum(percentage)) %>%
          # to make which group to put label over
          mutate(ethnicity = "Hispanic") %>%
          arrange(percentage)

        ggplot(plot_data, aes(fill=ethnicity, y=percentage, x=factor(race, levels = race_totals$race))) +
          geom_bar(position="stack", stat="identity") +
          geom_text(data = race_totals, aes(label = round(percentage * 100, digits = 1)), position=position_dodge(width=0.9),
                    hjust = -.15, color = "grey20", size = 3) +
          scale_y_continuous(labels = scales::percent) +
          scale_fill_viridis_d(begin = 0.2, end = 0.6, direction = -1,
                               guide = guide_legend(reverse = TRUE)) +
          coord_flip(clip = "off") +
          labs(title = "Proportion of Population by Race and Ethnicity",
               subtitle = paste0("Across all race categories, ",
                                 percent_hispanic,
                                 "% of the population identifies as Hispanic/Latinx"),
               caption = "Data from the 2014-2018 American Community Survey (ACS) 5-year estimates") +
          theme_census() +
          theme(
            legend.position = "bottom",
            legend.title = element_blank(),
            axis.title.y = element_blank(),
            axis.title.x = element_blank()
          )
      })
    })

  })
}

## To be copied in the UI
# mod_demographics_ui("demographics_ui_1")

## To be copied in the server
# mod_demographics_server("demographics_ui_1")
