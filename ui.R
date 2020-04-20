###################################################################################
# Title: ui.R                                                                     #
# Purpose: create user interface for running shiny app                            #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-19                                                       #
###################################################################################


library(shiny)
library(leaflet)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
    dateRangeInput("range", "Date of Run", 
      start = min(spl_df$start_date_local), 
      end = max(spl_df$start_date_local),
    )
  )
)