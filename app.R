###################################################################################
# Title: app.R                                                                    #
# Purpose: To build shiny app with running data                                   #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-18                                                       #  
###################################################################################


library(shiny)
library(leaflet)
library(RColorBrewer)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
    dateRangeInput("range", "Date of Run", 
      start = min(DT[,start_date_local]), 
      end = max(DT[,start_date_local]),
    )
  )
)

server <- function(input, output, session) {

  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    DT[start_date_local >= input$range[1] & start_date_local <= input$range[2],]
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(DT) %>% 
    addTiles(
      urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
      attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
    ) %>%
    fitBounds(~min(start_longitude), ~min(start_latitude), ~max(start_longitude), ~max(start_latitude))
  })

  observe({
    leafletProxy("map", data = filteredData()) %>%
      addCircles(lat= ~start_latitude, lng = ~start_longitude, radius = 10, weight = 1, color = "#777777"
      )
  })

}

shinyApp(ui, server)



rsconnect::setAccountInfo(name='pkluitenberg', token='CE791F2FD97DAE85E3DC2C650B9823A2', secret='N4OdDDjbiBmKrQU18N32Medp+8uk51XCV5IQfPE4')