###################################################################################
# Title: server.R                                                                 #
# Purpose: create server for running shiny app                                    #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-20                                                       #
###################################################################################

# Begin import packages
suppressMessages(suppressWarnings(library(shiny)))
suppressMessages(suppressWarnings(library(leaflet)))
suppressMessages(suppressWarnings(library(jsonlite)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(sp)))
suppressMessages(suppressWarnings(library(measurements)))
suppressMessages(suppressWarnings(library(ggplot2)))
# End import packages

# bind location variables
# its important that these are relative paths
# ShinyApps.io does not work with absolute paths
DATA_PATH = paste0("data/runs.json.gz")
SOURCE_PATH = paste0("source/functions.R")

# source functions
source(SOURCE_PATH)

# read in data
dt = setDT(fromJSON(DATA_PATH))

# convert to SpatialLinesDataFrame object
spl_df = poly_to_spatial(dt, poly_col = "map.summary_polyline",
                          decode_poly = TRUE) 

# define Shiny server

server <- function(input, output, session) {

  filteredData <- reactive({
    units = ifelse(input$units,"mi","km")
    spl_df$distance = conv_unit(spl_df$distance,from = "m",to = units)
    subset(spl_df, start_date_local >= input$range[1] &
          start_date_local <= input$range[2])
  })

  output$map <- renderLeaflet({
    leaflet(spl_df) %>% 
    addTiles(
      urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
      attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
    ) %>%
    # pre-set boundaries
    # could make these dynamic at some point but not important now
    fitBounds(-87.735277, 41.917473, -87.587440, 41.859110)
  })

  output$distance = renderText({
    round(sum(filteredData()$distance),digits = 0 )
  })

  output$dist_hist <- renderPlot({
    # If there is no data, don't output the plot
    if (nrow(filteredData()) == 0)
      return(NULL)

    ggplot(as.data.frame(filteredData()), aes(x=distance)) +
      geom_histogram(binwidth = 1, fill = "#69b3a2",color = "white") +
      xlab("Length of Run") +
      ylab("Frequency") +
      theme_classic() +
      scale_x_continuous(breaks = seq(0,max(round(filteredData()$distance)),1))
  })

  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>%   
      clearPopups() %>% 
      clearMarkers() %>%
      addPolylines(opacity = 0.4, weight = 3, color = "#69b3a2")
  })
}