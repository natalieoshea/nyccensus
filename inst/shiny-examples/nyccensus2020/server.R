function(input, output, session) {

  # App settings ----

  # share input across tabs
  observe({
    geo_map <- input$geo
    updateSelectInput(session, "geo2", selected = geo_map)
  })

  observe({
    geo_table <- input$geo2
    updateSelectInput(session, "geo", selected = geo_table)
  })

  # save census data from selected geography
  census_data <- reactive({
    get(paste0("rr_", input$geo))
  })

  # Map ----

  map_df <- reactive({
    get(paste0("geo_", input$geo)) %>%
      left_join(census_data()) %>%
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

  # print input$map_shape_click info
  observeEvent(input$map_shape_click, {
    map_shape_click <- input$map_shape_click
    print(map_shape_click)
  })

  # print input$map_click info
  observeEvent(input$map_click, {
    map_click <- input$map_click
    print(map_click)
  })

  # pair programming steps:
  # convert to leafletProxy for compatibility with
  # store map_shape_click ID
  # add polylines to leafletProxy object

  # Data table ----

  output$data_table <- DT::renderDataTable({

    # save crosswalk info
    crosswalk <- crosswalk_tract_2020 %>%
      select(input$geo2, borough, if(input$geo2 %in% c("nCode", "tract_2020")) "neighborhood") %>%
      unique()

    # save GEO_ID label info
    label <- case_when(input$geo2 == "nCode" ~ "Code",
                       input$geo2 == "tract_2020" ~ "Census Tract",
                       input$geo2 == "borough" ~ "Borough",
                       input$geo2 == "congressional" ~ "Congressional District",
                       input$geo2 == "stateSenate" ~ "State Senate District",
                       input$geo2 == "council" ~ "City Council District",
                       input$geo2 == "assembly" ~ "Assembly District",
                       input$geo2 == "school" ~ "School District",
                       input$geo2 == "commBoard" ~ "Community Board District",
                       input$geo2 == "modzcta" ~ "Zip Code")

    # wrangle datatable info
    filtered_df <- census_data() %>%
      # filter to selected date range
      filter(RESP_DATE >= min(input$dateRange) & RESP_DATE <= max(input$dateRange)) %>%
      # select relevant columns
      select(RESP_DATE, GEO_ID, CRRALL, CRRINT, DRRALL, DRRINT) %>%
      # add crosswalk info
      left_join(crosswalk, by = c("GEO_ID" = input$geo2)) %>%
      # filter to selected borough(s)
      filter(is.null(input$boro) | if (input$geo2 == "borough") {GEO_ID %in% input$boro} else {borough %in% input$boro}) %>%
      # rename columns
      rename("Date" = "RESP_DATE",
             "Cumulative Response Rate" = "CRRALL",
             "Cumulative Response Rate (Internet)" = "CRRINT",
             "Daily Response Rate" = "DRRALL",
             "Daily Response Rate (Internet)" = "DRRINT")

    # order and name columns based on user input
    table_df <- if(input$geo2 == "borough") {
      filtered_df %>%
        select(Date, GEO_ID, everything())
    } else if(input$geo2 == "nCode") {
      filtered_df %>%
        select(Date, borough, neighborhood, everything())
    } else if(input$geo2 == "tract_2020") {
      filtered_df %>%
        select(Date, borough, neighborhood, everything()) %>%
        # remove tract prefix
        mutate(GEO_ID = str_remove(GEO_ID, "1400000US360"))
    } else {
      filtered_df %>%
        select(Date, borough, everything())
    }

    # generate datatable
    table_df %>%
      # rename GEO_ID column with correct label
      rename(!!paste0(label) := "GEO_ID") %>%
      # make sure all column names are in title case
      rename_all(str_to_title) %>%
      # create DT object
      DT::datatable(rownames = FALSE, extensions = "Buttons",
                    options = list(dom = "Blrtip",
                                   buttons = c("copy", "csv", "pdf"),
                                   lengthMenu = list(c(10, 25, 50, -1),
                                                     c(10, 25, 50, "All"))))

  })

}
