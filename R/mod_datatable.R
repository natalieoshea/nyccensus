#' datatable UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_datatable_ui <- function(id){
  ns <- NS(id)
  tagList(
    DT::DTOutput(ns("dt"))
  )
}

#' datatable Server Functions
#'
#' @noRd
mod_datatable_server <- function(id, geo, dateRange, boro){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$dt <- DT::renderDT({

      # save crosswalk info
      crosswalk <- crosswalk_tract_2020 %>%
        select(geo(), borough, if(geo() %in% c("nCode", "tract_2020")) "neighborhood") %>%
        unique()

      # save GEO_ID label info
      label <- case_when(geo() == "nCode" ~ "Code",
                         geo() == "tract_2020" ~ "Census Tract",
                         geo() == "borough" ~ "Borough",
                         geo() == "congressional" ~ "Congressional District",
                         geo() == "stateSenate" ~ "State Senate District",
                         geo() == "council" ~ "City Council District",
                         geo() == "assembly" ~ "Assembly District",
                         geo() == "school" ~ "School District",
                         geo() == "commBoard" ~ "Community Board District",
                         geo() == "modzcta" ~ "Zip Code")

      # wrangle datatable info
      filtered_df <- rr_data[[geo()]] %>%
        # filter to selected date range
        filter(RESP_DATE >= min(dateRange()) & RESP_DATE <= max(dateRange())) %>%
        # select relevant columns
        select(RESP_DATE, GEO_ID, CRRALL, CRRINT, DRRALL, DRRINT) %>%
        # add crosswalk info
        left_join(crosswalk, by = c("GEO_ID" = geo())) %>%
        # filter to selected borough(s)
        filter(is.null(boro()) | if (geo() == "borough") {GEO_ID %in% boro()} else {borough %in% boro()}) %>%
        # rename columns
        rename("Date" = "RESP_DATE",
               "Cumulative Response Rate" = "CRRALL",
               "Cumulative Response Rate (Internet)" = "CRRINT",
               "Daily Response Rate" = "DRRALL",
               "Daily Response Rate (Internet)" = "DRRINT")

      # order and name columns based on user input
      table_df <- if(geo() == "borough") {
        filtered_df %>%
          select(Date, GEO_ID, everything())
      } else if(geo() == "nCode") {
        filtered_df %>%
          select(Date, borough, neighborhood, everything())
      } else if(geo() == "tract_2020") {
        filtered_df %>%
          select(Date, borough, neighborhood, everything()) %>%
          # remove tract prefix
          mutate(GEO_ID = stringr::str_remove(GEO_ID, "1400000US360"))
      } else {
        filtered_df %>%
          select(Date, borough, everything())
      }

      # generate datatable
      table_df %>%
        # rename GEO_ID column with correct label
        rename(!!paste0(label) := "GEO_ID") %>%
        # make sure all column names are in title case
        rename_all(stringr::str_to_title) %>%
        # create DT object
        DT::datatable(rownames = FALSE, extensions = "Buttons",
                      options = list(dom = "Blrtip",
                                     buttons = c("copy", "csv", "pdf"),
                                     lengthMenu = list(c(10, 25, 50, -1),
                                                       c(10, 25, 50, "All"))))

    })

  })
}

## To be copied in the UI
# mod_datatable_ui("datatable_ui_1")

## To be copied in the server
# mod_datatable_server("datatable_ui_1")
