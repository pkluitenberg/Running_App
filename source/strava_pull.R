###################################################################################
# Title: strava_get.R                                                             #
# Purpose: to make API requests to the Strava API to pull down my personal data   #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-19                                                       #  
###################################################################################

# Begin import packages
suppressMessages(suppressWarnings(library("yaml")))
suppressMessages(suppressWarnings(library("httr")))
suppressMessages(suppressWarnings(library("jsonlite")))
suppressMessages(suppressWarnings(library("data.table")))
suppressMessages(suppressWarnings(library("R.utils")))
# End import packages

# bind static variables
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")
DATA_DIR    = paste0(PARENT_DIR,"data/")
SOURCE_DIR  = paste0(PARENT_DIR,"source/")
DATA_PATH   = paste0(DATA_DIR,"runs.json")
URL         = "https://www.strava.com/api/v3/athlete/activities"

# source functions
source(paste0(SOURCE_DIR,"functions.R"))

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
dt = api_to_dt(URL, token)

# let's print the names of our data.table to see what is available
names(dt)

# let's print the number of rows in our data.table as well
message(paste0("Number of activities: ",dt[,.N]))

# let's filter down to just the runs. (Running is all that matters in life)
dt = dt[type == 'Run']
message(paste0("Number of runs: ",dt[,.N]))

# Let's also filter out any runs without a polyline because I can't map them
dt = na.omit(dt,cols = c("map.summary_polyline"))
message(paste0("Number of runs w/ GPS data: ",dt[,.N]))

# write data out to compressed JSON
write_json(dt, path = DATA_PATH, simplifyVector = TRUE)
gzip(DATA_PATH, destname = paste0(DATA_PATH,".gz"), remove = TRUE)