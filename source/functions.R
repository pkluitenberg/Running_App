###################################################################################
# Title: functions.R                                                              #
# Purpose: to declare functions used in this project                              #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-06-13                                                       #  
###################################################################################

# begin imports
suppressMessages(suppressWarnings(library(httr)))
suppressMessages(suppressWarnings(library(yaml)))
suppressMessages(suppressWarnings(library(jsonlite)))
suppressMessages(suppressWarnings(library(data.table)))
suppressMessages(suppressWarnings(library(httr)))
suppressMessages(suppressWarnings(library(sp)))
suppressMessages(suppressWarnings(library(lubridate)))
# end imports


# This function uses the current refresh token to check for a new access token

refresh_access_token = function(client_id, client_secret, refresh_token, cur_access_token, expires_at){

    # if the token expires in the next 60 seconds or is past its expiration date, we refresh
    if((expires_at-60) >= now("UTC")){
        message("Access token is stale. Requesting new access token...")
        
        auth_specs = list(client_id = client_id, 
                client_secret = client_secret, 
                grant_type = 'refresh_token',
                refresh_token = refresh_token)

        # post request
        r = POST(url = "https://www.strava.com/api/v3/oauth/token", # Strava authentication endpoint
            body = auth_specs)

        # warn us if our request is bad
        warn_for_status(r)

        # writing out our authentication info
        write_yaml(content(r),paste0(CONFIG_DIR,"tokens.yml"))
        
        message("Access token refreshed!")

    } else {
        message("Access token is still fresh.")
    }

}

# this function checks if there are any new runs compared to the data saved locally
check_new_run = function(athlete_id, cur_run_cnt, access_token, token_type){

    r <- GET(
                url = paste0("https://www.strava.com/api/v3/athletes/",athlete_id,"/stats"),
                add_headers(Authorization = paste(token_type, access_token, sep = " ")),
                content_type("application/json")
            )

    new_run_cnt = content(r)$all_run_totals$count

    if(cur_run_cnt != new_run_cnt){
        return TRUE
    } else {
        return FALSE
    }
}


# this function returns the id of the logged in athlete
get_athlete_id = function(access_token, token_type){

    r <- GET(
            url = "https://www.strava.com/api/v3/athlete",
            add_headers(Authorization = paste(token_type, access_token, sep = " ")),
            content_type("application/json")
        )
    
    return content(r)$id
}


# this function querys the provided API and returns data in a data.table
api_to_dt = function(access_token, token_type = "Bearer", page_len = 100){
    
    # bind local vars
    done = FALSE
    page_num = 1
    dt = data.table()

    # you can specify how many results come through on a page so we'll loop through to make smaller pulls
    while (!done){
        # make request to strava API
        r = GET(
            url = "https://www.strava.com/api/v3/athlete/activities",
            add_headers(Authorization = paste(token_type, access_token, sep = " ")),
            content_type("application/json"),
            query = list(per_page = page_len, page = page_num)
        )
        # append it to the data.table    
        dt <- rbindlist(list(dt,
            fromJSON(content(r, as = "text"),flatten = TRUE)),
            use.names = TRUE
        )
        # stop requesting once we can't fill any more pages
        if (length(content(r)) < page_len){
            done = TRUE
        } else {
            page_num = page_num + 1
        }  
    }

    return(dt)
}

# this function takes data table of poylines and converts it to a Spatial Lines Data Frame
# using the sp package. This allows for the lines to be nicely mapped using leaflet or another package.
# input is a data.table. I think it should also work with a data.frame
poly_to_spatial = function(dt, poly_col, decode_poly = FALSE){
    
    # define temporary column name for poyline because data.table is
    # really terrible with variables as column names
    setnames(dt,poly_col,"temp_polyline")

    # if the user provides an encoded polyline, we'll use googlePolylines to decode it
    # this will return a data.frame in each row of the data.table with each lat & lon 
    if (decode_poly){
        suppressMessages(suppressWarnings(library("googlePolylines")))
        dt[, temp_polyline := 
            lapply(dt[, temp_polyline],decode)] 
    }
    # build a list of Spatial Lines    
    lst_lines <- lapply(1:dt[,.N], function(x){
        ## make sure longitude is ordered first and the latitude
        Lines(Line(dt[x, temp_polyline[[1]]][, c('lon','lat')]), ID = x)
    })

    # convert our list of lines to a Spatial Object
    spl_list = SpatialLines(lst_lines)

    # attaches our Spatial Lines objects to our data.table
    # matches Spatial Lines objects ID to row names in data.table
    spl_df = SpatialLinesDataFrame(spl_list,data = dt,match.ID=TRUE)

    return(spl_df)

}
