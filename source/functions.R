###################################################################################
# Title: functions.R                                                              #
# Purpose: to declare functions used in this project                              #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-20                                                       #  
###################################################################################

# this function querys the provided API and returns data in a data.table
api_to_dt = function(url, token, page_len = 100){

    # begin import packages
    suppressMessages(suppressWarnings(library(jsonlite)))
    suppressMessages(suppressWarnings(library(data.table)))
    suppressMessages(suppressWarnings(library(httr)))
    # end import packages

    # bind variables
    done <- FALSE
    data_lst <- list()
    i <- 1
    dt = data.table()


    while (!done){
        # make request to strava API
        request <- GET(
            url = url,
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

    return(dt)
}

# this function takes data table of poylines and converts it to a Spatial Lines Data Frame
# using the sp package. This allows for the lines to be nicely mapped using leaflet or another package.
# input is a data.table. I think it should also work with a data.frame
poly_to_spatial = function(dt, poly_col, decode_poly = FALSE){
    
    # begin import packages
    suppressMessages(suppressWarnings(library(sp)))
    suppressMessages(suppressWarnings(library(data.table)))
    # end import packages

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
