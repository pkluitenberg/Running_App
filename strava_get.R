###################################################################################
# Title: strava_get.R                                                                #
# Purpose: to make API requests to the Strava API to pull down my personal data   #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-18                                                       #  
###################################################################################

# Begin import packages
library("yaml")
library("httr")
library("jsonlite")
library("data.table")
library("leaflet")
library("googlePolylines")
library("R.utils")
# End import packages

# bind location variables
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")
DATA_DIR    = paste0(PARENT_DIR,"data/")
SOURCE_DIR  = paste0(PARENT_DIR,"source/")

# read in config file to get static log in info to API
CONFIG          = read_yaml(paste0(CONFIG_DIR,"config.yml"))
CLIENT_ID       = CONFIG$client_id
CLIENT_SECRET   = CONFIG$secret

# create OAuth app for strava named "strava"
app <- oauth_app("strava", 
            key=CLIENT_ID,
            secret=CLIENT_SECRET)

# create endpoint to request OAuth token
endpoint <- oauth_endpoint(
            request = NULL, # using OAuth 2.0 so leave null
            authorize = "https://www.strava.com/oauth/authorize",
            access = "https://www.strava.com/oauth/token")

# request OAuth token
token <- oauth2.0_token(endpoint, app,
            as_header = FALSE,
            scope = "activity:read_all")

# loop through to request data in chunks of 100 activities
# I don't have enough activities to actually be concerned about the amount
# i'm pulling but who cares \_(*_*)_/
# I like to think that I will have more than 32 activities one day
done <- FALSE
data_lst <- list()
i <- 1
DT = data.table()
page_len = 100

while (!done){
    # make request to strava API
    request <- GET(
        url = "https://www.strava.com/api/v3/athlete/activities",
        config = token,
        query = list(per_page = page_len, page = i)
    )
    # append it to the data.table    
    DT <- rbindlist(list(DT,
        fromJSON(content(request, as = "text"),flatten = TRUE)),
        use.names = TRUE
    )
    # stop requesting once we can't fill any more pages
    if (length(content(request)) < page_len){
        done <- TRUE
    } else {
        i <- i + 1
    }  
}

# let's get this data written on out to JSON file (need less structure than CSV)
# this way we don't need to call the API that often at the moment
# I only run once a day so no need for frequent calls
write_json(DT, path = paste0(DATA_DIR,"run_data.json"), pretty = TRUE)

# read in data
DT = setDT(read_json(paste0(DATA_DIR,"run_data.json"), simplifyVector = TRUE))

# let's print the names of our data.table to see what is available
names(DT)

# let's print the number of rows in our data.table as well
message(paste0("Number of activities: ",DT[,.N]))

# let's filter down to just the runs. (Running is all that matters in life)
DT = DT[type == 'Run']

# For posterity, let's check the number of rows again to see how many runs I have
message(paste0("Number of runs: ",DT[,.N]))




# testing testing 1 2 3 
cities <- read.csv(textConnection("
City,Lat,Long,Pop
Boston,42.3601,-71.0589,645966
Hartford,41.7627,-72.6743,125017
New York City,40.7127,-74.0059,8406000
Philadelphia,39.9500,-75.1667,1553000
Pittsburgh,40.4397,-79.9764,305841
Providence,41.8236,-71.4222,177994
"))

leaflet() %>% addTiles()

dt[,map.summary_polyline_decoded:= lapply(dt[,map.summary_polyline],decode)]

head(dt,1)

list(unlist(dt[,end_latlng])[c(TRUE,FALSE)])

cbindlist(dt,list(unlist(dt[,end_latlng])[c(TRUE,FALSE)]))

dt[,!c("V2")]

m <- leaflet() %>%
  addTiles() %>%
  addMarkers(lng = -81.677590, lat = 41.892160,
             popup = "Home")

m