function(input, output, session) {

  # output$map: base map ----
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      addProviderTiles(
        provider = "CartoDB.Positron",
        options = providerTileOptions(minZoom = 10, maxZoom = 20)
      ) %>%
      setView(lng = -74.05, lat = 40.71, zoom = 11) %>%
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }")
  })

}
