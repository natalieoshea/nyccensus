navbarPage("NYC Census 2020",
           id = "nav",

           # Map ----

           tabPanel(
             "Map",
             div(
               tags$head(includeCSS("styles.css")),
               class = "outer",

               leafletOutput("map", width = "100%", height = "100%"),

               absolutePanel(
                 id = "controls", class = "panel panel-default",
                 top = 75, left = 55, width = 250, fixed=TRUE,
                 draggable = TRUE, height = "auto",

                 h4("Response Rates"),

                 selectInput("var", "Variable", census_vars),
                 selectInput("geo", "Geography", census_geos),
                 dateInput("date", "Date",
                           value = max(rr_tract_2020$RESP_DATE),
                           min = min(rr_tract_2020$RESP_DATE),
                           max = max(rr_tract_2020$RESP_DATE)
                 ),


               )
             )
           )

)
