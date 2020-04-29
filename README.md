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


**Link to published app:**  https://pkluitenberg.shinyapps.io/run_app/

### Index
- [Getting Started](#getting-started)
- [Dependencies](#dependencies)
- [Code Overview](#code-overview) 
- [Open Items](#open-items)
- [Resources](#resources)

### Getting Started

If you're interested in using this to host your own app, there is a little bit of up front work to get yourself access to the Strava API and to set up a ShinyApps.io account. Below is a link to a tutorial on how to get access to the Strava API and a link to ShinyApps.io.

Once you get the above two items set up, you are pretty much good to go. You can clone this repository to your local machine using git clone with either HTTPS or SSH.
```bash
$ git clone https://github.com/pkluitenberg/Running_App.git
```
Next, you'll need to head into the `/config/` folder and enter your credentials for the Strava API and ShinyApps.io in the two yaml files. Once you've updated the files, you can remove the *example_* prefix from the file names using the following command (you could also just use `mv` twice but this is more fun):
```bash
$ for file in example_*; do mv "$file" "${file#example_}"; done;
```
This last step will be easy to eliminate but I have yet to. My source scripts both are hardcoded to point to "~/repos/run_app" as the parent directory. If you have your repo sitting somewhere else or named something else, you will need to change those references.

I think after you finish these three steps, you should be up and running.

### Dependencies
All packages can be installed using the following command in your R terminal

```R
install.packages(c("data.table",
                   "httr",
                   "jsonlite",
                   "R.utils",
                   "sp",
                   "googlePolylines",
                   "yaml",
                   "shiny",
                   "leaflet",
                   "measurements",
                   "rsconnect"))
```

### Code Overview

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
- Add a histogram of miles per run
- Add a conversion between kilometers & miles
- Add in average pace or graph or rolling average pace
- Add in popups with basic run info when you click on a route
### Resources
 - Great tutorial on accessing Strava API with R: https://bldavies.com/blog/accessing-strava-api/
 - ShinyApps.io: https://www.shinyapps.io/
 - Shiny SuperZip example: https://shiny.rstudio.com/gallery/superzip-example.html
