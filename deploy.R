#!/usr/bin/env Rscript

###################################################################################
# Title: deploy.R                                                                 #
# Purpose: this script deploys the shiny app to shinyapps.io                      #
# Author: Paul Kluitenberg                                                        #
# Last Modified: 2020-04-20                                                       #
###################################################################################

# begin import packages
suppressMessages(suppressWarnings(library(rsconnect)))
suppressMessages(suppressWarnings(library(yaml)))
# end import packages

# bind static variables
PARENT_DIR  = "~/repos/run_app/"
CONFIG_DIR  = paste0(PARENT_DIR,"config/")

# read in config file for auth specs
CONFIG          = read_yaml(paste0(CONFIG_DIR,"shiny.yml"))
TOKEN           = CONFIG$token
SECRET          = CONFIG$secret
ACCT_NAME       = CONFIG$acct_name

# authorize account
rsconnect::setAccountInfo(name=ACCT_NAME,	
			  token=TOKEN,
			  secret=SECRET)

# deploy app
rsconnect::deployApp(PARENT_DIR)
