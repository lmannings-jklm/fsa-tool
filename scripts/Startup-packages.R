# Personal Access Token handler

install.packages("usethis")
library(usethis)
create_github_token() # This opens GitHub to generate a token

# Post-token handler

install.packages("gitcreds")
library(gitcreds)
gitcreds_set("https://github.com/lmannings-jklm/fsa-tool.git") # Paste your token here


# Test the connection with a test file

writeLines("# Test File\nThis confirms my Git connection is working.", "git_test.md")

# Initialize the environment with `renv` and install

install.packages("renv")
renv::init()

# Install the package that permits tidyverse to communicate with Google API

install.packages("googledrive")

# Snapshot the state. This creates an `renv.lock` file which acts as the "DNA" of your project dependencies.

renv::snapshot()

# Establish an OAuth 2.0 connection using `garg`
library(googledrive)

# Authorize and cache the token in a non-interactive-friendly way
drive_auth(email = "lmannings@jklmdata.net")

# Test the connection
drive_find(n_max = 5)


# Run this code in your script to verify that r-drive-bot can talk to Google Drive

library(googledrive)

# 1. Point to your new key
drive_auth(path = "secrets/google-key-r-drive-bot.json")

# 2. Test the connection
# Note: This will be empty at first because the Robot has its own empty Drive!
drive_find(n_max = 5)


# Create .Renviron file
# If you don't have usethis, install it first: install.packages("usethis")
usethis::edit_r_environ(scope = "project")

# Add this to any script to type the path to the google drive key

library(googledrive)

# R pulls the path automatically from your .Renviron
drive_auth(path = Sys.getenv("GOOGLE_DRIVE_KEY"))

# Test it
drive_user()

# R will look at the email and automatically find the matching token/key
drive_auth(email = Sys.getenv("GDRIVE_EMAIL"))

#---------------------------------------------------------------------------
# The "Ultimate" Verification Script
#---------------------------------------------------------------------------

library(googledrive)

# 1. Login using the key path
drive_auth(path = Sys.getenv("GOOGLE_DRIVE_KEY"))

# 2. Print a status message to the console
message(paste("Connected to Google Drive as:", Sys.getenv("GDRIVE_EMAIL")))

# 3. Double-check that the Robot's name matches what you expected
drive_user()


