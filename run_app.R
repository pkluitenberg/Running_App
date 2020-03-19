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
# End import packages

# read in config file to get log in info to API
CONFIG          = read_yaml("~/repos/run_app/config/config.yml")
CLIENT_ID       = cfg$client_id
CLIENT_SECRET   = cfg$secret

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

# make request to strava API
request <- GET(url = "https://www.strava.com/api/v3/athlete/activities",
            config = token,
            query = list(per_page = 200, page = 1))

data = fromJSON(content(req, as = "text"), flatten = TRUE)
dt = setDT(data)[type=="Run"]
str(dt)
dt2 = dt

dt2[,start_lat:=start_latlng[[1]][1]]
dt