#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @import leaflet
#' @import dplyr
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    leaflet::leafletOutput(ns("map"), width = "100%", height = "100%")
  )
}

#' map Server Functions
#'
#' @noRd
mod_map_server <- function(id, var, geo, date){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    # save census data from selected geography
    census_data <- reactive({
      rr_data[[geo()]]
    })

    # create mapping data frame
    map_df <- reactive({
      sf::st_as_sf(geo_data[[geo()]]) %>%
        left_join(census_data()) %>%
        filter(RESP_DATE == date())
    })

    # set base map
    output$map <-  leaflet::renderLeaflet({
      leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
        # move zoom to upper right
        htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
        }") %>%
        addProviderTiles(
          provider = "CartoDB.Positron",
          options = providerTileOptions(minZoom = 10, maxZoom = 20)
        ) %>%
        setView(lng = -74.1, lat = 40.7, zoom = 11)
    })

    # add colors to polygons
    observe({
      pal <- colorNumeric("viridis", map_df()[[var()]])
      var <- map_df()[[var()]]

      leaflet::leafletProxy("map", data = map_df()) %>%
        clearShapes() %>%
        clearControls() %>%
        addPolylines(
          data = map_df(),
          weight = 1,
          color = "grey"
        ) %>%
        addPolygons(
          data = map_df(),
          layerId = ~GEO_ID,
          color = ~pal(var),
          fillOpacity = 0.7,
          smoothFactor = 0,
          stroke = FALSE
        ) %>%
        addLegend(
          data = map_df(),
          pal = pal,
          values = ~var,
          labFormat = labelFormat(suffix = "%"),
          title = "",
          "bottomright"
        )
    })

    # store map_shape_click ID as a reactive value
    clickedShape <- reactiveVal(NA)

    observeEvent(input$map_click, {
      if (is.null(input$map_shape_click)) {
        # if input#map_shape_click hasn't been initiated, set clickedShape() to NA
        clickedShape(NA)
      } else if (input$map_click$lat == input$map_shape_click$lat &
                 input$map_click$lng == input$map_shape_click$lng) {
        # save polygon value
        val <- map_df() %>% filter(GEO_ID == input$map_shape_click$id) %>% pull("CRRALL")
        # if value is NA, set clickedShape() to NA
        ifelse(is.na(val), clickedShape(NA), clickedShape(input$map_shape_click$id))
      } else {
        # if user clicks outside a polygon, set clickedShape() to NA
        clickedShape(NA)
      }
    })

    # if user switches geographies, set clickedShape() to NA
    observeEvent(geo(), {
      clickedShape(NA)
    })

    # highlight clickedShape() polygon
    observeEvent(clickedShape(), {

      if (!is.na(clickedShape())) {
        # save clickedShape() geometry
        clicked_polygon <- map_df()$geometry[map_df()$GEO_ID %in% clickedShape()]

        # add highlight polylines
        leaflet::leafletProxy("map") %>%
          clearGroup("highlights") %>%
          addPolylines(data = clicked_polygon,
                       stroke = TRUE,
                       weight = 5,
                       color = "darkblue",
                       group = "highlights")
      } else {
        # remove previously highlighted polylines
        leaflet::leafletProxy("map") %>%
          clearGroup("highlights")
      }

    })

  })
}

## To be copied in the UI
# mod_map_ui("map_ui_1")

## To be copied in the server
# mod_map_server("map_ui_1")
