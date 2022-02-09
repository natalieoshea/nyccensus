#' languages UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import ggplot2 dplyr
mod_languages_ui <- function(id){
  ns <- NS(id)
  tagList(
    plotOutput(ns("languages"))
  )
}

#' languages Server Functions
#'
#' @noRd
mod_languages_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$languages <- renderPlot({
      # save language from acs data
      language_data <- nyccensus::demos_data[["nyc"]] %>%
        select(contains("Language_")) %>%
        pivot_longer(
          cols = everything(),
          names_to = c("group", "language", "type"),
          names_sep = "_",
          values_to = "percentage"
        ) %>%
        select(-group) %>%
        mutate(language = recode(language,
                                 "OnlyEnglish" = "Only English",
                                 "LimitedEnglish" = "Limited English",
                                 "FrenchCreole" = "French Creole",
                                 "OtherWestGermanic" = "Other West Germanic",
                                 "SerboCroatian" = "Serbo-Croatian",
                                 "OtherSlavic" = "Other Slavic",
                                 "OtherIndic" = "Other Indic",
                                 "OtherIndoEuropean" = "Other Indo-European",
                                 "OtherPacificIsland" = "Other Pacific Island",
                                 "OtherNativeNorthAmerican" = "Other Native North American",
                                 "AfricanLanguages" = "African Languages",
                                 "OtherAndUnspecifiedLanguages" = "Unspecified"),
               type = recode(type, "LimitedEnglish" = "Limited English"))

      # save limited english population
      limited_english <- language_data %>%
        filter(language == "Limited English") %>%
        mutate(percentage = round(percentage * 100, digits = 1)) %>%
        pull(percentage)

      # not in helper
      # `%not_in%` <- Negate(`%in%`)

      # pull top 5 foreign languages
      top_5_languages <- language_data %>%
        filter(type == "Total" & language %not_in% c("Only English", "Limited English")) %>%
        arrange(desc(percentage)) %>%
        slice(1:5) %>%
        pull(language)

      # plot data frame
      plot_data <- language_data %>%
        filter(language %in% top_5_languages) %>%
        pivot_wider(
          names_from = type,
          values_from = percentage
        ) %>%
        mutate(`English Proficient` = Total - `Limited English`) %>%
        pivot_longer(
          cols = -c(language, Total),
          names_to = "type",
          values_to = "percentage"
        )

      # save language totals
      language_totals <- plot_data %>%
        filter(type == "English Proficient") %>%
        mutate(percentage = Total)

      # plot
      ggplot(plot_data, aes(fill=type, y=percentage, x=reorder(language, Total))) +
        geom_bar(position="stack", stat="identity") +
        geom_text(data = language_totals,
                  aes(label = round(Total * 100, digits = 1)),
                  position=position_dodge(width=0.9),
                  hjust = -.15, color = "grey20", size = 3) +
        scale_y_continuous(labels = scales::percent) +
        scale_fill_viridis_d(begin = 0.2, end = 0.6, direction = -1,
                             guide = guide_legend(reverse = TRUE)) +
        coord_flip() +
        labs(title = "Top 5 Foreign Languages Spoken",
             subtitle = paste0("Across all languages, ",
                               limited_english,
                               "% of the population has limited English proficiency"),
             caption = "Data from the 2011-2015 American Community Survey (ACS) 5-year estimates") +
        theme_census() +
        theme(
          legend.position = "bottom",
          legend.title = element_blank(),
          axis.title.y = element_blank(),
          axis.title.x = element_blank()
        )
    })
  })
}

## To be copied in the UI
# mod_languages_ui("languages_ui_1")

## To be copied in the server
# mod_languages_server("languages_ui_1")
