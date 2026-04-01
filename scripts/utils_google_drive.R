# ==============================================================================
# Script: utils_google_drive.R
# Purpose: Line commands for pushing R Project date to Google Workplace
# Author: Larry Mannings
# Organization: JKLM Data Analytics
# Date: 2026-03-26
# ==============================================================================

# 1. Load Environment & Libraries
source("./scripts/00_setup.R")

# Capture the correct project root at the start
project_root <- getwd()


# Search for the folder and store its ID
project_folder <- drive_get("5. Querying & Quality Assurance")

# Define the files you want to upload
files_to_upload <- c("./outputs/fsa_candidates_report.pdf")

# Loop through and upload them to the project folder
for (file in files_to_upload) {
    drive_upload(
        media = file,
        path = as_id(project_folder), # Uploads directly into your project folder
        name = file,                  # Keeps the same filename
        overwrite = TRUE              # Overwrites if you run this multiple times
    )
}

# List all files in that folder
drive_ls(as_id(project_folder))
