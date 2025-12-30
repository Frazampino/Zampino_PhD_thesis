# Procurement-to-Pay (P2P) Event Log Generator

## Overview
This R script generates **Procurement-to-Pay (P2P) event logs** from raw enterprise data. It transforms original files such as purchase requests, orders, invoices, contracts, and suppliers into standardized CSV files ready for **process mining** and analysis.  

The goal is to provide a clean, anonymized, and consistent dataset reflecting the P2P lifecycle: **from purchase request to payment**.


## Technical Compliance & XES Standard
A key feature of this pipeline is the formalization of data quality procedures through a custom **KNIME Component**: 
🔗 **[XES Data Quality Checker](https://hub.knime.com/francescazampin/spaces/Public/Component~JSTJdzQ4rM_t7Nm1)**

This component acts as a **technical validation gate**. Since standard Process Mining tools (like Disco, ProM or Apromore) and KNIME nodes (like *Table to Event Log*) require strict adherence to the XES standard, this tool ensures:

* **Exact Deduplication:** Automatically removes technical merging errors (identical rows) while preserving legitimate repeated events to maintain process semantics.
* **Structural Integrity:** Fixes missing case IDs and malformed timestamps that would otherwise cause the XES export to fail.
* **Scientific Auditability:** Generates a dedicated quality report documenting every correction (e.g., handling of >8,200 missing values via forward-fill).
---
## Pre-Experimental Setup

Before running the Procurement-to-Pay (P2P) data preparation pipeline, ensure the following setup is completed:

### 1. System Requirements
- **Operating System:** Windows 10 / 11, macOS 12+, or Linux (Ubuntu 20.04+ recommended)
- **R:** Version 4.2 or higher
- **KNIME Analytics Platform:** Version 5.1 or higher
- **Memory:** Minimum 8 GB RAM (16 GB recommended for large datasets)
- **Storage:** At least 5 GB free space for raw and processed data

### 2. Install R Packages
Install the required R packages using the following commands:

r
install.packages(c("tidyverse", "lubridate", "readr", "dplyr", "stringr"
## Reproducibility Protocol

Follow these steps to reproduce the P2P event log:

1. **Install dependencies**: Install all required R packages and KNIME extensions.
2. **Import raw ERP data**: Place raw CSV files in `data/raw/` and run `01_import.R`.
3. **Standardize formats**: Execute `02_transform.R` to clean and harmonize column names, data types, and activity labels.
4. **Handle missing values**: Run `03_impute.R` to fill missing dates and amounts, and impute end dates for open cases.
5. **Remove duplicates**: Run `04_deduplicate.R` to remove duplicated entries and ensure unique case identifiers.
6. **Export final logs**: Execute `05_export.R` to generate fully standardized, pseudonymized event logs in `data/final/`.
7. **Optional visual inspection**: Open `workflow.knwf` in KNIME to validate transformations, inspect quality metrics, and visualize process paths.

Following this protocol will produce:

- Fully structured, chronologically ordered, pseudonymized P2P event logs  
- Quantitative data quality metrics (completeness, consistency, accuracy, reliability)  

---

## Data Privacy

All sensitive information has been pseudonymized. The mapping between original and anonymized identifiers is maintained internally but **not included** in the repository to protect privacy.

---

## Versioning and Portability

- All scripts and data are versioned using Git.  
- The repository is licensed under **CC BY 4.0** for reuse and adaptation.  
