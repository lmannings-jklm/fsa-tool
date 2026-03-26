# ==============================================================================
# Script: utils_id_mapping.R
# Purpose: Maps Google Drive IDs/Names to anonymized Customer IDs
# Author: Larry Mannings
# Organization: JKLM Data Analytics
# Date: 2026-03-26
# ==============================================================================

# Convert Google Drive Names to Customer IDs
#
# `drive_names` A vector of names/IDs found in the data (e.g., from the drive_id column)
# `drive_vals` A unique vector of all possible Drive IDs to use as a reference index
#  Return A character vector of anonymized customer IDs (e.g., "cust_1")
change2custid <- function(drive_names, drive_vals) {
    
    # Find the index position of each drive_name within the reference drive_vals
    # This replaces the nested for-loops for better performance
    matched_indices <- match(drive_names, drive_vals)
    
    # Create the "cust_X" string based on that index
    cust_ids <- paste0("cust_", matched_indices)
    
    return(cust_ids)
}