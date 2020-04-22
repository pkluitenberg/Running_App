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
    subset(spl_df,start_date_local >= input$range[1] & start_date_local <= input$range[2])
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

  observe({
    leafletProxy("map", data = filteredData()) %>%
      clearShapes() %>% 
      clearPopups() %>% 
      clearMarkers() %>%
      addPolylines(opacity = 0.4, weight = 3, color = "#ff0000")
  })
}