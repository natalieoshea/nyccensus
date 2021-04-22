function(input, output, session) {

  map_df <- reactive({
    get(paste0("geo_", input$geo)) %>%
      left_join(get(paste0("rr_", input$geo))) %>%
      filter(RESP_DATE == input$date)
  })


  output$map <- renderLeaflet({
    pal <- colorNumeric("viridis", map_df()[[input$var]])
    var <- map_df()[[input$var]]

    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      addProviderTiles(
        provider = "CartoDB.Positron",
        options = providerTileOptions(minZoom = 10, maxZoom = 20)
      ) %>%
      setView(lng = -74.05, lat = 40.71, zoom = 11) %>%
      addPolylines(
        data = map_df(),
        weight = 1,
        color = "grey"
      ) %>%
      addPolygons(
        data = map_df(),
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

}
