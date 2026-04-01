![Header Image](header-photo.png)

# R Project: Transform Amazon Order History for FSA Reimbursements

# Introduction

The triple tax advantage of a [Health Savings Account](https://www.healthcare.gov/high-deductible-health-plan/) (HSA) means that your initial contributions are tax-deductible, your invested balance grows tax-free, and any withdrawals made for qualified medical expenses are completely exempt from income taxes. However, in order to capitalize on the third HSA tax advantage (Tax-Free Withdrawals), one would need to establish a record archiving process and environment to provide proof that any out-of-pocket reimbursements were valid. This proof is required to satisfy a potential IRS audit and avoid the 20% non-qualified withdrawal penalty.

Maintaining digital-first approach for our record keeping and using a secured cloud storage such as Google Drive as a repository makes this process easy to maintain. Collecting the receipts for provider appointments and prescriptions is relatively straightforward as there is an Explanation of Benefits documented with our health care insurance account claim summary or some other type of billing statement for medical services provided. What is a bit more complicated to track down are itemized purchases of Flexible Spending Account (FSA) Eligible Expenses. If you don't retain or digitally archive receipts for these purchases frequently, obtaining a reimbursement does not appear possible for a large number of such items. One source of comfort is that online stores such as **Amazon.com** allow you to download your order history, so obtaining records of FSA Eligible Expenses appear to be within reach. While a PDF invoice is the required format for proof of purchase, navigating the order history aids in finding the desired order numbers corresponding to the qualified expenses, which can be used to view the invoice on the online store.

It is worthwhile to explore how one goes about converting Amazon Order History into actionable data that can be queried to yield only the purchase orders that contain FSA eligible data. It should also be noted that this order history will contain personally identifiable information such as shipping/billing addresses, payment methods, shopping habits and indicators of health conditions. Some additional work will be required to sanitize the data to make it safe for a public walkthrough while also keeping it useful.

# Project Overview

This project demonstrates the use of data wrangling skills to convert personal order history data into a format that can be searched for purchases that meet IRS FSA eligibility criteria. The project will leverage the R Tidyverse package to convert the raw order history data into tidy format. The data will be queried to yield the desired order history relevant to FSA eligible purchases. The order history is privacy sensitive, so we will need to sanitize the data to generalize dates, mask personal information, and obfuscate price data, while permitting the end user to utilize the output for follow on tasks.

## R Packages Used

The following libraries and options are called from `00_setup.R` and are required for implementation:

> `tidyverse`  for data wrangling and visualization tools
>
> `rmarkdown`  orchestrates the process of generating multiple output formats
>
> `knitr`  powers R Markdown by handling the execution of embedded R code
>
> `kableExtra`  extends the basic functionality of tables produced by the `knitr` package
>
> `scales`: Provides functions for human readable labels for axes and legends
>
> `googledrive`  allows interaction with Google Drive directly from R
>
> `usethis`  automates repetitive tasks that arise during project setup and development
>
> `renv` helps you create reproducible environments for your R projects
>
> `janitor`: Contains additional "tidyverse" - oriented tools for cleaning "dirty" data
>
> `webshot2`: Tools for document preparation
>
> `pagedown`: Allows for full control of a documents borders

## Key Questions

1.   How can we effectively identify and map the key variables within the raw order history to distinguish FSA-eligible purchases from non-eligible ones?
2.   How can we scrub and generalize the data to protect privacy while still permitting the end user to accurately query for FSA eligibility?

# Installation and Setup

## Prerequisites

To run this project you need R (v4.0 or higher) and RStudio Desktop installed.

## Obtain the Project Files

The source code, raw dataset, and documentation are hosted on this GitHub repository.

1. Click the green **Code** button and select **Download ZIP**.
2. Extract the ZIP file to a dedicated directory on your local machine (e.g. `C:\Documents\Project-FSA` )

## Initialize the Project

This project uses an `.Rproj` file to ensure reproducibility. By opening the project through this file, RStudio automatically sets the working directory to the project root, ensuring that all file paths (for data ingestion and exports) function correctly without the need for manual adjustment.

- Navigate to your local project folder and double-click `fsa-tool.Rproj`.

## Configure the Environment

to ensure the project runs with the exact package versions and settings used during development, follow these three configuration steps:

### A. (Optional) Handle Environment Variables (`.Renviron`)

This project can pull raw data directly from Google Drive. To facilitate this securely, we use environment variables. Otherwise, this step is not necessary.

1. **Locate the template:** Find the file named `.Renviron_example` in the root directory.
2. **Create your local file:** Copy this file and rename it to exactly `.Renviron`.
3. **Update Credentials:** Open your new `.Renviron` and add your specific Google Service Account paths and emails.
4. **Security: DO NOT** commit your `.Renviron` to version control. It is already included in the `.gitignore` to prevent sensitive API keys from being published to GitHub.

_RStudio will automatically load these variables when you open the `.Rproj` file._

### B. Restore the Package Library

As noted in the `00_setup.R` script, this project uses renv to create a private, isolated libraary. This prevents verdion conflicts with you other R projects. To synchronize your local library with the project requirements, run:

```{r}
# Run this in the RStudio Console
renv::restore()
```

This command will read the `renv.lock` file and automatically install the correct versions of `tidyverse`, `digest`, `googledrive`, and other `dependencies`.

### C. Initialize the Session (`00_setup.R`)

Once the packages are installed, you must initialize your R session. This script loads all required libraries, configures "blank slate" settings, and sets global options (like preventing scientific notation for Order IDs).

Run the following command in your console: `source("./scripts/01_data_ingestion.R")`

**You should see the message**: `Setup complete: All libraries loaded and options configured.`


# Project Resources & Infrastructure

This project utilizes a secure Google Workspace Drive environment to isolate Personally Identifiable Information (PII) and provide a centralized hub for stakeholder collaboration outside of the R development environment.

## Data Access & Security

To comply with data privacy standards, no raw data or PII is stored in this GitHub repository. All restricted datasets are housed in an access-controlled Google Drive folder.

- **R Integration:**  The analytical scripts access the necessary data dynamically from Google Drive (see *R Packages* section)
- **Access Requirements**  Executing the R scripts requires explicit read permissions to the secured Google Drive directory. Unauthorized users will experience execution failures at the data-ingestion step.
- **Security Protocol**  Contributors must not download raw PII data to unencrypted local drives. Ensure all local environment files (such as `.RData` and `.Rhistory`) are strictly excluded from version control.

## Stakeholder Collaboration & Project Management
To maintain a single source of truth and streamline project management, all non-technical workflows are managed within Google Workspace.

-  **Project Workspace:**  [**R Project: Transform Amazon Order History for FSA Reimbursements**](https://drive.google.com/drive/folders/1hqstW0ofnQ1mbBZm3NxQxZGykSZtYnFb?usp=drive_link) (access restricted to non-stakeholders)
-  **Deliverables & Reviews:**  Rendered outputs (e.g., Markdown reports, HTML files, visualizations) are exported from R directly to the `Deliverables/` subfolder in Drive for stakeholder review.
-  **Feedback Loop:**  Stakeholders, analysts, and project sponsors should utilize the integrated Google Docs and Sheets within the project folder for tracking milestones, providing feedback, and managing approvals.


# Data

## Source Data

The source data for this project is Amazon order history that must be requested and downloaded from the **Amazon.com Privacy Data Central** and requires an account login. Once requested and available, the dataset format can be downloaded in `.csv` format. For the primary case study, the scope of the data pertains to two individual Amazon.com accounts with order history data extending back to January 1<sup>st</sup> , 2019.

## Data Acquisition

The source data for each user must be uploaded manually to the privacy access controlled project folder `/Secure_client_data_PII`. The source data will be manipulated in the '/data` folder of the local R project repository, so the folder `.gitignore` file to ensure sensitive data never makes it to GitHub repository.

## Data Preprocessing

The source data is not presumed to meet [**tidy data** standards](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html). Additional data wrangling will be required.

# Project Structure

Project Repository structure is outlined below.

``` text
C:.
│   .gitignore
│   .Rprofile
│   fsa-tool.Rproj
│   header-photo.png
│   README.html
│   README.md
│   renv.lock
│   tree_diagram.txt
│
├───assets
│       JKLM-Logo-scaled.jpg
│
├───docs
│ 
├───functions
│       utils_id_mapping.R
│
├───notebooks
│       01a_data_exploration.html
│       01a_data_exploration.qmd
│
├───outputs
│       fsa_candidates_report.pdf
│
├───renv
├───scripts
│       00_setup.R
│       01_data_ingestion.R
│       Startup-packages.R
│       utils_google_drive.R
│
├───src
│
└───trainer_data
        Amazon_FSA_Audit_Trainer.csv
```

# Results and Evaluation

The project results are published and maintained by [**JKLM Data Analytics**](jklmdata.net) and can be found [HERE](https://jklmdata.net/portfolio/fsa-tool/).

# Acknowledgements / References

Image Credits - The project header image was generated using Google Gemini 3 Flash (Engine: Nano Banana 2).

[**IRS Publication 502: Medical and Dental Expenses**](https://www.irs.gov/forms-pubs/about-publication-502)  Explains the itemized deduction for medical and dental expenses that you claim on your tax form.     
