#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    leaflet::leafletOutput(ns("map"), height = "90vh")
  )
}

#' map Server Functions
#'
#' @noRd
mod_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # set base map
    output$map <-  leaflet::renderLeaflet({
      leaflet::leaflet(options = leaflet::leafletOptions(zoomControl = FALSE)) %>%
        leaflet::addProviderTiles(
          provider = "CartoDB.Positron",
          options = leaflet::providerTileOptions(minZoom = 10, maxZoom = 20)
        ) %>%
        leaflet::setView(lng = -74.05, lat = 40.71, zoom = 11)
    })

  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")
