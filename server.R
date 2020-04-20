###################################################################################
# Title: server.R                                                                 #
# Purpose: create server for running shiny app                                    #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-19                                                       #
###################################################################################


library("shiny")
library("leaflet")
library("jsonlite")
library("data.table")
library("googlePolylines")
library("sp")




# read in data
dt = setDT(read_json(paste0(DATA_DIR,"run_data.json"), simplifyVector = TRUE))

# let's print the names of our data.table to see what is available
names(DT)

# let's print the number of rows in our data.table as well
message(paste0("Number of activities: ",DT[,.N]))

# let's filter down to just the runs. (Running is all that matters in life)
DT = DT[type == 'Run']

# For posterity, let's check the number of rows again to see how many runs I have
message(paste0("Number of runs: ",DT[,.N]))

# Let's also filter out any runs without a polyline because I can't map them
DT = na.omit(DT,cols = c("map.summary_polyline"))

message(paste0("Number of runs w/ GPS data: ",DT[,.N]))

# decode polylines for mapping
DT[,map.summary_polyline_decoded:= lapply(DT[,map.summary_polyline],decode)]

# Select & rename columns
DT = DT[,c("id","type","distance","start_date_local","start_latitude","start_longitude","map.summary_polyline_decoded")]
setnames(DT,"map.summary_polyline_decoded","decoded_polyline")

lst_lines <- lapply(unique(DT$id), function(x){
    ## the order of the 'lon' and 'lat' fields is important
    Lines(Line(DT[x == id,decoded_polyline[[1]]][,c(2,1)]), ID = x)
})

df = as.data.frame(DT)
row.names(DT) = DT$id
DT$id = NULL
DT[,decoded_polyline := NULL]
spl_list = SpatialLines(lst_lines)

spl_df = SpatialLinesDataFrame(spl_list,data = DT,match.ID=TRUE)



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