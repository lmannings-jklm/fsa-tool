# ======================================================================================
# Script: 00_setup.R
# Purpose: Initialize environment, install / load required packages, and set options
# Author: Larry Mannings
# Organization: JKLM Data Analytics
# Date: 2026-03-18
# =====================================================================================

# 1. Load Packages
# Because we are using renv, we trust these are already installed in the private library.
    library(tidyverse)    # Core data manipulation (dplyr, stringr, lubridate, etc.)
    library(rmarkdown)    # Document rendering
    library(knitr)        # Power R Markdown by handling the execution of embedded R code
    library(kableExtra)   # Extends the basic functionality of tables produced by `knitr` package
    library(digest)       # Provides functions that create unique "signatures" (hash sums) representing input data
    library(scales)       # Provides functions for human readable labels for axes and legends  
    library(usethis)      # Automates repetitive tasks that arise during project setup and development
    library(googledrive)  # Google Workspace API integration
    library(janitor)      # Contains additional `tidyverse` - oriented tools for cleaning "dirty" data
    library(webshot2)     # Tools for document preparation
    library(pagedown)     # Allows for full control of document borders


# 2. Configure the Blank Slate 
# (Ensures your workspace stays clean across sessions)
usethis::use_blank_slate(scope = "project")

# 3. Global Project Options
# Prevents scientific notation for long order IDs
options(scipen = 999)
# Sets console output to 3 significant digits for cleaner viewing
options(digits = 3)

message("Setup complete: All libraries loaded and options configured.")
# ======================================================================================