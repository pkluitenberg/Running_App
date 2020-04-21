# Running Data Shiny App
This January, I was contacted by the SOA (Society of Actuaries) and asked to provide some 
feedback on their CAA designation (hint: don't get it). They offered to pay me $200 for a 30 minute phone call. 
Absolutely unreal. So, I decided to take my recently acquired nest egg and buy myself a Garmin running watch. 
Four months later, and that watch has accompanied me on every run since. 

I have primarily used Strava to track all my running data. However, the free version of strava is a little basic
so I thought it would be fun to try to build some of the views I wanted to see. Strava has a simple, easy to use API
which allowed me to get to my running data without much trouble.

I was in the middle of an R project at work and my friend Ryan ([@ryanpeiffer](https://github.com/ryanpeiffer)) had previously shown me Shiny and ShinyApps.io (RStudio's
Shiny application hosting service). I thought this would be a great opportunity to give those two applications a try.

### Index
- [Getting Started](#getting-started)
- [Overview](#overview)
- [Open Items](#open-items)
- [Resources](#resources)

### Getting Started
### Overview

This application consists of five total R scripts.
1. /source/functions.R

    - Currently there are two functions in this script.
    ```R
    # Pulls data down from URL using provided authenitcation and writes to a data.table
    api_to_dt = function(url, token, page_len = 100){}
    ```
    
    ```R
    # reads in data.table with polylines (decoded or encoded) in a column.
    # converts the polylines into Spatial Objects using the 'sp' package
    # outputs SpatialLineDataFrame with the original columns in the data.table plus the Spatial Objects
    poly_to_spatial = function(dt, poly_col, decode_poly = FALSE){}
    ```

2. /source/strava_pull.R
    - Walks through the authentication to the Strava API (using oauth2.0) and calls
    the api_to_dt() function to write down a gzipped JSON file of the strava data
3. ui.R
    - Builds the user interface for the Shiny app
4. server.R
    - Builds the backend of the shiny app - filters data based on user inputs, draws polylines, and renders the map 
5. deploy.R
    - Deploys the shiny app to ShinyApps.io


### Open Items
### Resources
