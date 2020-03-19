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

# read in config file to get static log in info to API
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
        query = list(per_page = 100, page = page_len)
    )
    # append it to the data.table    
    dt <- rbindlist(list(dt,
        fromJSON(content(request, as = "text"),flatten = TRUE)),
        use.names = TRUE
    )
    if (length(content(request)) < page_len){
        done <- TRUE
    } else {
        i <- i + 1
    }  
}