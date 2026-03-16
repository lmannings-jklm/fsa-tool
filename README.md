![Header Image](header-photo.png)

# R Project: Transform Amazon Order History for FSA Order History

## Introduction

The triple tax advantage of a [Health Savings Account](https://www.healthcare.gov/high-deductible-health-plan/) (HSA) means that your initial contributions are tax-deductible, your invested balance grows tax-free, and any withdrawals made for qualified medical expenses are completely exempt from income taxes. However, in order to capitalize on the third HSA tax advantage (Tax-Free Withdrawals), one would need to establish a record archiving process and environment to provide proof that any out-of-pocket reimbursements were valid. This proof is required to satisfy a potential IRS audit and avoid the 20% non-qualified withdrawal penalty.

Maintaining digital-first approach for our record keeping and using a secured cloud storage such as Google Drive as a repository makes this process easy to maintain. Collecting the receipts for provider appointments and prescriptions is relatively straightforward as there is an Explanation of Benefits documented with our health care insurance account claim summary or some other type of billing statement for medical services provided. What is a bit more complicated to track down are itemized purchases of Flexible Spending Account (FSA) Eligible Expenses. I you don't retain or digitally archive receipts for these purchases frequently, obtaining a reimbursement does not appear possible for a large number of such items. One source of comfort is that online stores such as Amazon allow you to download your order history, so obtaining records of FSA Eligible Expenses appear to be within reach. While a PDF invoice is the required format for proof of purchase, navigating the order history aids in finding the desired order numbers corresponding to the qualified expenses, which can be used to view the invoice on the online store.

It is worthwhile to explore how one goes about converting Amazon Order History into actionable data that can be queried to yield only the purchase orders that contain FSA eligible data. It should also be noted that this order history will contain personally identifiable information such as shipping/billing addresses, payment methods, shopping habits and indicators of health conditions. Some additional work will be required to sanitize the data to make it safe for a public walkthrough while also keeping it useful.

# Project Overview

This project demonstrates the use of data wrangling skills to convert personal order history data into a format that can be searched for purchases that meet IRS FSA eligibility criteria. The project will leverage the R Tidyverse package to convert the raw order history data into tidy format. The data will be queried to yield the desired order history relevant to FSA eligible purchases. The order history is privacy sensitive, so we will need to sanitize the data to generalize dates, mask personal information, and obfuscate price data, while permitting the end user to utilize the output for follow on tasks.

## Key Questions

1.   How can we effectively identify and map the key variables within the raw order history to distinguish FSA-eligible purchases from non-eligible ones?
2.   How can we scrub and generalize the data to protect privacy while still permitting the end user to accurately query for FSA eligibility?

# Installation and Setup

## Codes and Resources

-   **Editor:** RStudio 2026.01.0 Build 392
-   **R Version:** 4.5.0 (2025-04-11 ucrt)

## R Packages Used

The following libraries and options are required to complete the assignment

> `library(tidyverse)`  for data wrangling and visualization tools
>
> `library(rmarkdown)`  orchestrates the process of generating multiple output formats
>
> `library(knitr)`  powers R Markdown by handling the execution of embedded R code
>
> `library(kableExtra)  extends the basic functionality of tables produced by the `knitr` package
>
> library(digest) provides functions that creates unique “signatures” (hash sums) that represent input data
>
> library(googledrive)  Allows interaction with Google Drive directly from R

## Version Control

GitHub repository for code archival and collaboration

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

The source data for this project can be found in the `extdata` directory of the **dslabs** package, which contains the daily mortality data for Puerto Rico from Jan 1, 2015 to May 31, 2018.

## Data Acquisition

Once the dslabs package is installed, the file is located in the package's external data directory, accessed in R using a command like this:

> `fn <- system.file("extdata", "RD-Mortality-Report_2015-18-180531.pdf", package="dslabs")`

## Data Preprocessing

The source data is not presumed to meet [**tidy data** standards](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html). Additional data wrangling will likely be required.

# Project Structure

Project Repository structure is outlined below.

``` text
pr-hurr-mortality
│   header-photo.png
│   README.md
│
├───data
│
├───docs
│
├───notebooks
│       RD-Mortality-Report_2015-18-180531.pdf
│
├───scripts
│       pr_hurr_scrubber.html
│       pr_hurr_scrubber.R
│       pr_hurr_scrubber.Rmd
│
└───src
```

# Results and Evaluation

The project results are captured in the R markdown file [**pr_hurr_scrubber.Rmd**](https://github.com/lmannings-jklm/pr-hurr-mortality/blob/main/scripts/pr_hurr_scrubber.Rmd), which is included in this repository.

# Acknowledgements / References

This project was originally constructed and submitted towards completion of requirements for the [**HarvardX PH125.6x Data Science: Wrangling**](https://www.edx.org/learn/data-science/harvard-university-data-science-wrangling) certificate, in March 2026.

Image Credits - The project header image was generated using Google Gemini 3 Flash (Engine: Nano Banana 2).
