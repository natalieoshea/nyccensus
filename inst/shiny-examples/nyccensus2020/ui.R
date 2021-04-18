navbarPage("NYC Census 2020",
           id = "nav",

           # Map ----

           tabPanel(
             "Map",
             div(
               class = "outer",

               # tags$head(includeCSS("styles.css"), includeScript("gomap.js")),

               leafletOutput("map", width = "100%", height = "100%"),

               absolutePanel(
                 id = "controls", class = "panel panel-default", fixed = TRUE,
                 draggable = TRUE, top = 60, left = 10, right = "auto", bottom = "auto",
                 width = 400, height = "auto",

                 h3("Response Rates"),

                 selectInput("var", "Variable", census_vars),
                 selectInput("geo", "Geography", census_geos),


               )
             )
           ),

           tabPanel(
             "Data"
           )

)
