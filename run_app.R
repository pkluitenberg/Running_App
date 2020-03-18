library("yaml")
library('httr')
library('jsonlite')
library('data.table')

CONFIG          = read_yaml("~/repos/run_app/config/config.yml")
CLIENT_ID       = cfg$client_id
CLIENT_SECRET   = cfg$secret

app <- oauth_app("strava",CLIENT_ID, CLIENT_SECRET)

endpoint <- oauth_endpoint(
  request = NULL,
  authorize = "https://www.strava.com/oauth/authorize",
  access = "https://www.strava.com/oauth/token"
)

token <- oauth2.0_token(endpoint, app, as_header = FALSE,
                        scope = "activity:read_all")

req <- GET(url = "https://www.strava.com/api/v3/athlete/activities",config = token,query = list(per_page = 200, page = 1))
print(req)

data = fromJSON(content(req, as = "text"), flatten = TRUE)