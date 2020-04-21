###################################################################################
# Title: server.R                                                                 #
# Purpose: create server for running shiny app                                    #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-19                                                       #
###################################################################################

# Begin import packages
library("shiny")
library("leaflet")
library("jsonlite")
library("data.table")
library("googlePolylines")
library("sp")
# End import packages

# bind location variables
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")
DATA_DIR    = paste0(PARENT_DIR,"data/")
SOURCE_DIR  = paste0(PARENT_DIR,"source/")

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
    fitBounds(~min(start_longitude), ~min(start_latitude), ~max(start_longitude), ~max(start_latitude))
  })

  observe({
    leafletProxy("map", data = filteredData()) %>%
      addPolylines(opacity = 0.4, weight = 3, color = "#ff0000")
  })

}