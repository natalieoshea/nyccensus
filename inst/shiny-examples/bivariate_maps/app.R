# prep ----

# load libraries
library(tidyverse)
library(sf)
library(biscale)
library(basemapR)

# load data
map <- nyccensus::geo_nCode
df <- nyccensus::demos_nCode

# save variables
vars <- names(df)
vars <- vars[-(1:5)]

# app ----

ui <- fluidPage(

  titlePanel("Bivariate Maps of NYC Neighborhoods"),

  sidebarLayout(

    sidebarPanel(
      selectInput("xvar", label = "X variable",
                  choices = vars, selected = "Language_LimitedEnglish_Total"),

      selectInput("yvar", label = "Y variable",
                  choices = vars, selected = "HealthInsurance_NotCovered")
    ),

    mainPanel(

      plotOutput("map")

    )
  )
)

server <- function(input, output, session) {

  reactive_df <- reactive({
    df %>%
      select(GEO_ID, input$xvar, input$yvar) %>%
      rename(xvar = !!as.name(input$xvar),
             yvar = !!as.name(input$yvar))
  })

  output$map <- renderPlot({
    # calculate bi-classes
    df_bi <- bi_class(reactive_df(), x = xvar, y = yvar) %>%
      mutate(bi_class = ifelse(str_detect(bi_class, "NA"), NA, bi_class))

    # join data
    map_df <- map %>%
      left_join(df_bi)

    # map
    ggplot() +
      base_map(st_bbox(map_df), basemap = "dark", increase_zoom = 2, nolabels = TRUE) +
      geom_sf(data = map_df, aes(fill = bi_class), color = "lightgrey",
              size = 0.1, show.legend = FALSE) +
      bi_scale_fill(pal = "DkBlue", dim = 3) +
      theme(axis.line = element_blank(),
            axis.text = element_blank(),
            axis.ticks = element_blank(),
            axis.title = element_blank(),
            panel.grid = element_blank(),
            panel.border = element_blank())
  })

}
