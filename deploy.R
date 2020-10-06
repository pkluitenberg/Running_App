#!/usr/bin/env Rscript

###################################################################################
# Title: deploy.R                                                                 #
# Purpose: this script deploys the shiny app to shinyapps.io                      #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-07-20                                                       #
###################################################################################

suppressMessages(suppressWarnings(library(yaml)))
suppressMessages(suppressWarnings(library(httr)))
suppressMessages(suppressWarnings(library(jsonlite)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(R.utils)))
suppressMessages(suppressWarnings(library(rsconnect)))

# read in our auth specs YAML file
PARENT_DIR          = "~/repos/run_app/"
CONFIG_DIR          = paste0(PARENT_DIR,"config/")
SOURCE_PATH         = paste0("source/functions.R")
DATA_PATH           = paste0("data/runs.json")
DATA_PATH_GZIP      = paste0("data/runs.json.gz")
CLIENT_CONFIG       = read_yaml(paste0(CONFIG_DIR,"client.yml"))
TOKEN_CONFIG        = read_yaml(paste0(CONFIG_DIR,"tokens.yml"))
SHINY_CONFIG        = read_yaml(paste0(CONFIG_DIR,"shiny.yml"))

# import functions.R
source(SOURCE_PATH)

# bind variables
client_id           = CLIENT_CONFIG$client_id
client_secret       = CLIENT_CONFIG$secret
refresh_token       = TOKEN_CONFIG$refresh_token
access_token        = TOKEN_CONFIG$access_token
expires_at          = TOKEN_CONFIG$expires_at
token_type          = TOKEN_CONFIG$token_type
shiny_token         = SHINY_CONFIG$token
shiny_secret        = SHINY_CONFIG$secret
shiny_acct_name     = SHINY_CONFIG$acct_name

# load current data into memory and get run count
dt = setDT(fromJSON(DATA_PATH_GZIP))
cur_run_cnt = dt[,.N]

# check if we have a stale token and refresh it if need be
refresh_access_token(client_id = client_id,
                        client_secret = client_secret,
                        refresh_token = refresh_token,
                        cur_access_token = access_token,
                        expires_at = expires_at)

# get athlete id
ath_id = get_athlete_id(access_token,token_type)

# check if we have any new runs
new_run = check_new_run(athlete_id = ath_id, 
                            cur_run_cnt = cur_run_cnt, 
                            access_token = access_token, 
                            token_type = token_type)

# refresh data if we have new runs
if(new_run){
    # get data from api
    dt1 = api_to_dt(access_token, token_type)    

    # filter down to just runs
    dt1 = dt1[type == "Run"]
    
    # write it out
    write_json(dt1, path = DATA_PATH, simplify_vector = TRUE, pretty = TRUE)
    gzip(DATA_PATH, destname = DATA_PATH_GZIP, overwrite = TRUE, remove = TRUE)

}

# authorize shinyapps.io account
rsconnect::setAccountInfo(name=shiny_acct_name,	
			  token=shiny_token,
			  secret=shiny_secret)

# deploy app
rsconnect::deployApp(PARENT_DIR)
