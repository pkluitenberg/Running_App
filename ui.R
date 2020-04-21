###################################################################################
# Title: ui.R                                                                     #
# Purpose: create user interface for running shiny app                            #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-19                                                       #
###################################################################################

# begin import packages
suppressMessages(suppressWarnings(library(shiny)))
suppressMessages(suppressWarnings(library(leaflet)))
suppressMessages(suppressWarnings(library(jsonlite)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(sp)))
# end import packages

# bind location variables
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")
DATA_DIR    = paste0(PARENT_DIR,"data/")
SOURCE_DIR  = paste0(PARENT_DIR,"source/")
DATA_PATH   = paste0(DATA_DIR,"runs.json.gz")

# source functions
source(paste0(SOURCE_DIR,"functions.R"))

# read in data
dt = setDT(fromJSON(DATA_PATH))

# convert to SpatialLinesDataFrame object
spl_df = poly_to_spatial(dt, poly_col = "map.summary_polyline",
                          decode_poly = TRUE)

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