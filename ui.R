###################################################################################
# Title: ui.R                                                                     #
# Purpose: create user interface for running shiny app                            #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-07-20                                                       #
###################################################################################

# begin import packages
suppressMessages(suppressWarnings(library(shiny)))
suppressMessages(suppressWarnings(library(leaflet)))
suppressMessages(suppressWarnings(library(jsonlite)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(sp)))
suppressMessages(suppressWarnings(library(shinyWidgets)))
# end import packages

# bind location variables
# its important that these are relative paths
# ShinyApps.io does not work with absolute paths
DATA_PATH   = paste0("data/runs.json.gz")
SOURCE_PATH = paste0("source/functions.R")

# source functions
source(SOURCE_PATH)

# read in data
dt = setDT(fromJSON(DATA_PATH))
dt = na.omit(dt,cols = c("map.summary_polyline"))

# convert to SpatialLinesDataFrame object
spl_df = poly_to_spatial(dt, poly_col = "map.summary_polyline",
                          decode_poly = TRUE)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  tags$head(includeCSS("format.css")),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(id = "controls", top = 10, left = "auto", right = 10, 
                bottom = "auto", width = 325, height = "auto", 
                class = "panel panel-default", draggable = TRUE,
    fluidRow(
      column(8,h2("My Run Map")),
      column(4, align = "right", 
        switchInput("units", value = TRUE, onLabel = "mi", 
          offLabel = "km", size = "small", inline = TRUE,
        )
      )
    ),
    dateRangeInput("range", "Date of Run", 
      start = min(spl_df$start_date_local), 
      end = max(spl_df$start_date_local),
    ),
    h2("Total Distance Run"),
    textOutput("distance"),
    plotOutput("dist_hist", height = 200)
  )
)