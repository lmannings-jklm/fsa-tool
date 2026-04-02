# ==============================================================================
# Script: utils_spot-check.R
# Purpose: Randomly select a portion of the rows from amazon_tidy dataset for spot-check analysis
# Author: Larry Mannings
# Organization: JKLM Data Analytics
# Date: 2026-04-01
# ==============================================================================

# create a subset of randomly selected  rows from the original dataset (without replacement)

spot_check <- amazon_tidy |> sample_frac(size = 0.01)

# output the data to a spreadsheet

write_csv(spot_check, "C:/Users/laree/Downloads/FSA_spot-check.csv")

