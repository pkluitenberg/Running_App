###################################################################################
# Title: run_app.R                                                                #
# Purpose: to make API requests to the Strava API to pull down my personal data   #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-03-18                                                       #  
###################################################################################

# Begin import packages
library("yaml")
library('httr')
library('jsonlite')
library('data.table')
library("leaflet")
library("googlePolylines")
# End import packages

# read in config file to get static log in info to API
CONFIG          = read_yaml("~/repos/run_app/config/config.yml")
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
dt = data.table()
page_len = 100

while (!done){
    # make request to strava API
    request <- GET(
        url = "https://www.strava.com/api/v3/athlete/activities",
        config = token,
        query = list(per_page = page_len, page = i)
    )
    # append it to the data.table    
    dt <- rbindlist(list(dt,
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
# let's print the names of our data.table to see what is available
names(dt)







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