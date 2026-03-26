# ==============================================================================
# Script: 01_data_ingestion.R
# Purpose: Securely pull client Amazon data from Drive, parse, and flag FSA items.
# Author: Larry Mannings
# Organization: JKLM Data Analytics
# Date: 2026-03-18
# ==============================================================================

# 1. Load Environment & Libraries
source("./scripts/00_setup.R")

# Load custom functions
source("./functions/utils_id_mapping.R")

# Capture the correct project root at the start
project_root <- getwd()

# 2. Identify your Drive Folder (Use the folder name or ID)
drive_folder <- drive_ls(path = "~/Projects/R Project: Transform Amazon Order History for FSA Reimbursements/Private/Secure_client_data_PII", pattern = "\\.csv$")

# 3. Function to Download -> Read -> Cleanup
read_drive_csv <- function(drive_file) {
    # Create a temporary path on your local machine
    temp_path <- tempfile(fileext = ".csv")
    
    # Download from Drive to that temp path
    drive_download(drive_file, path = temp_path, overwrite = TRUE)
    
    # Read the CSV into R
    message("Ingesting data into R...")
    data <- read_csv(temp_path, col_types = cols(.default = "c")) |>
        janitor::clean_names()
    
    # DELETE THE FILE from your hard drive
    unlink(temp_path)
    message("Temporary file destroyed.")
    
    return(data)
}

# 4. Use map_df to iterate through the drive_folder list
amazon_combined <- drive_folder %>%
    split(.$id) %>% # Split the tibble so map sees individual files
    map_df(~ read_drive_csv(.x), .id = "drive_id")

# (Optional) Remove the Drive metadata from the environment
rm(drive_folder)


# Define the regex pattern for FSA eligible items 
fsa_keywords <- regex("face\\smask|FSA\\sHSA|N95\\smask|thermometer|first\\said|
                     bandage|sunscreen|light\\stherapy|medical|brace|sanitizer|
                     tylenol|\\sadvil\\s|covid|therapy", ignore_case = TRUE)

# 5. Tidyverse Transformation
amazon_tidy <- amazon_combined |> 
    select(drive_id, order_id, order_date, product_name, currency, total_amount) |> # reduce data set to the key variables
    # 5.1 Type Conversion 
    mutate(
        # Clean currency: Remove $, commas, and convert to numeric
        across(total_amount, 
               ~as.numeric(str_remove_all(.x, "[\\$,]"))),
        
        # Convert dates using lubridate (mdy is standard for Amazon US exports)
        order_date = ymd_hms(order_date)
    ) |>
    # Generalize the date to MM-YYYY format
    mutate(order_date = paste0(month(order_date), "-", year(order_date))) |>
    
    # 5.3 Data Integrity: Remove duplicates identified in exploration
    distinct(order_id, product_name, order_date, .keep_all = TRUE) |>
    
    # 5.4 Change unique drive file ids to customer ids
    rename(cust_id = drive_id) |>   # change column name to reflect customer ids
    mutate(cust_id = change2custid(cust_id, unique(cust_id)))


# 6 Filter for FSA Eligibility
fsa_candidates <- amazon_tidy |> filter(str_detect(product_name, fsa_keywords))  # filter dataset for FSA Eligible matches

# 6.1 Add FSA Category
fsa_candidates <- fsa_candidates |>
    mutate(
        fsa_category = case_when(
            # Bucket 1: PPE & Prevention
            str_detect(product_name, regex("face\\smask|N95\\smask|sanitizer|covid", ignore_case = TRUE)) ~ "PPE & Prevention",
            
            # Bucket 2: Medical Devices
            str_detect(product_name, regex("thermometer|brace|light\\stherapy|therapy|medical", ignore_case = TRUE)) ~ "Medical Devices",
            
            # Bucket 3: First Aid & OTC Meds
            str_detect(product_name, regex("first\\said|bandage|tylenol|advil", ignore_case = TRUE)) ~ "First Aid & OTC",
            
            # Bucket 4: General FSA/HSA
            str_detect(product_name, regex("FSA\\sHSA|sunscreen", ignore_case = TRUE)) ~ "General FSA/HSA",
            
            # Default: If it doesn't match above, label it NA
            TRUE ~ NA_character_
        )
    ) |> select(cust_id, order_id, order_date, product_name, fsa_category, currency, total_amount)

# 7 Add noise to mask exact price data
# modify 'total_amount` from it's original value by a randomly selected +/- 25% margin
fsa_candidates <- fsa_candidates |>
        mutate(
            # Step 1: Calculate the numeric value
            total_amount = as.numeric(total_amount) * runif(n(), 0.75, 1.25),
            
            # Step 2: Format as currency using across()
            # we use ~dollar(.x) to apply the function to the values
            across(total_amount, ~dollar(.x)) 
        )
# 8. Optional: Mask `product_name` data for public facing dataset
# Comment if not concerned about masking `product_name` date
# fsa_candidates <- fsa_candidates |> 
#     mutate(product_name = str_replace(product_name, "^(.{4}).*(.{4})$", "\\1..........\\2"))

# Additional pre-export formatting required
fsa_candidates <- fsa_candidates |>
    mutate(
        # 1. Replace the problematic '&' with 'and' 
        # (This is the safest way to avoid LaTeX column errors)
        fsa_category = str_replace_all(fsa_category, "&", "and"),
        
        # 2. Clean 'Product Name': Replace special spaces and limit the dots
        product_name = product_name |>
            str_replace_all("\\xa0", " ") |>        # Replace non-breaking spaces with normal ones
            str_replace_all("\\.{5,}", "...."),    # Shrink long dot strings to just 4 dots
        
        # 3. Final ASCII check (removes any other invisible Amazon junk)
        across(where(is.character), ~iconv(.x, "UTF-8", "ASCII", sub = ""))
    )

# Print a quick summary to the console to verify execution
message(paste("Success! Found", nrow(fsa_candidates), "potential FSA eligible items for review."))

# 9. Export PDF Report
# Ensure the directory exists (it's ignored by git, so we create it if missing)
if (!dir.exists("outputs")) {
    dir.create("outputs")
}

# 10 Create the PDF Table
# 10.1 Prepare data (Sort it so the index matches the rows!)
fsa_report_data <- fsa_candidates |>
    arrange(fsa_category) |>
    # Safety: ensure no LaTeX-breaking characters in the grouping column
    mutate(fsa_category = str_replace_all(fsa_category, "&", "and"))


# 10.2 Generate Table

# Ensure Chrome has time to breathe
Sys.sleep(1) 

logo_path <- file.path(project_root, "assets", "JKLM-Logo-scaled.jpg")
current_timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M")
logo_uri <- knitr::image_uri(logo_path)

# Build the Table HTML separately
html_table <- fsa_report_data |>
    select(cust_id, order_id, order_date, product_name, currency, total_amount) |> 
    kable(
        format = "html", 
        escape = TRUE, 
        col.names = c("Customer ID", "Order ID", "Date", "Product Name", "Currency", "Total")
    ) |>
    kable_styling(bootstrap_options = c("striped"), full_width = TRUE) |>
    row_spec(0, bold = TRUE) |> 
    # Force Order ID (Col 2) and Date (Col 3) to stay on one line
    column_spec(2:3, extra_css = "white-space: nowrap;") |>
    # Give Product Name (Col 4) more room and ensure it wraps
    column_spec(4, width = "40%", extra_css = "word-break: break-word;") |>
    pack_rows(index = table(fsa_report_data$fsa_category)) |>
    footnote(
        general = "This report is for reimbursement candidate identification only. Seek support from a profession if using this report for tax purposes.",
        general_title = "<b>Disclaimer: </b>", 
        escape = FALSE 
    ) |>
    as.character()

# --- 3. Combine into a Branded Document (Landscape Version) ---
final_html <- paste0(
    "<html><head><style>",
    # 1. FORCE LANDSCAPE ORIENTATION
    "@page { size: landscape; margin: 0.5in; }",
    
    # 2. Font & Global Layout
    "body { font-family: 'Cambria', 'Lora', serif; margin: 0; padding: 0; }",
    "table { border-collapse: collapse; width: 100%; margin-top: 20px; border: none !important; }",
    "th, td { padding: 12px 10px; text-align: left; border: none !important; }",
    "th { border-bottom: 2px solid #333 !important; font-weight: bold; }",
    
    # 3. Zebra Stripes (with print-color-adjust for stability)
    "tbody tr:nth-child(even) { 
        background-color: #f2f2f2 !important; 
        -webkit-print-color-adjust: exact; 
    }",
    
    # 4. Group Headers (pack_rows)
    "tr.group-header td { 
        background-color: #ffffff !important; 
        font-weight: bold; 
        padding-top: 20px; 
        border-bottom: 1px solid #999 !important; 
    }",
    
    # 5. Branding Layout
    ".header-container { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        border-bottom: 2px solid #333; 
        padding-bottom: 10px; 
    }",
    "</style></head><body>",
    "<div class='header-container'>",
    "<img src='", logo_uri, "' style='height: 60px;'>",
    "<div style='text-align: right;'>",
    "<strong style='font-size: 1.2em;'>JKLM Data Analytics</strong><br>",
    "<span style='font-weight: bold; color: #444;'>Customer FSA Eligibility Report</span><br>",
    "Report Generated: ", current_timestamp,
    "</div>",
    "</div>",
    html_table,
    "</body></html>"
)

# --- 4. Save to PDF with Landscape Settings ---
tmp_html <- tempfile(fileext = ".html")
writeLines(final_html, tmp_html)

pagedown::chrome_print(
    input = tmp_html,
    output = file.path(project_root, "outputs", "fsa_candidates_report.pdf"),
    browser = browser_path, 
    wait = 2,           
    timeout = 120,      
    options = list(
        displayHeaderFooter = TRUE,
        printBackground = TRUE, 
        footerTemplate = "
            <div style='font-family: serif; font-size: 10px; width: 100%; text-align: right; padding-right: 0.5in;'>
                pg <span class='pageNumber'></span> of <span class='totalPages'></span>
            </div>"
        # Note: We removed the margins here because they are now controlled 
        # by the CSS '@page' rule for better landscape consistency.
    ),
    extra_args = c("--disable-gpu", "--no-sandbox")
)

message("PDF Report rendered to ./output/")
# ==============================================================================