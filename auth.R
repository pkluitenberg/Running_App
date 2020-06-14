suppressMessages(suppressWarnings(library(httr)))
suppressMessages(suppressWarnings(library(yaml)))

# read in our auth specs YAML file
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")
CONFIG      = read_yaml(paste0(CONFIG_DIR,"strava_test.yml"))

# set POST request auth specs

auth_specs = list(client_id = CONFIG$client_id, 
                  client_secret = CONFIG$secret, 
                  grant_type = 'refresh_token',
                  refresh_token = CONFIG$refresh_token)
# refresh token

r = POST(url = "https://www.strava.com/api/v3/oauth/token",
         body = auth_specs)

print(paste0("POST status code: ", status_code(r)))

new_access_token = content(r)$access_token


# if the access token has expired, the auth_specs will
# be rewritten with the new access token
if(new_access_token != CONFIG$access_token){
    CONFIG$access_token = new_access_token
    write_yaml(content(r),paste0(CONFIG_DIR,"strava_test.yml"))
    print("yeet")
}

# now make request for data
request <- GET(
            url = "https://www.strava.com/api/v3/athlete/activities",
            add_headers(Authorization = paste(CONFIG$token_type, CONFIG$access_token, sep = " ")),
            content_type("application/json"),
            query = list(per_page = 100, page = 1)
        )