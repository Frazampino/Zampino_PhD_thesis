# Procurement-to-Pay (P2P) Event Log Generator

## Overview
This R script generates **Procurement-to-Pay (P2P) event logs** from raw enterprise data. It transforms original files such as purchase requests, orders, invoices, contracts, and suppliers into standardized CSV files ready for **process mining** and analysis.  

The goal is to provide a clean, anonymized, and consistent dataset reflecting the P2P lifecycle: **from purchase request to payment**.

---

## Features
- Reads raw CSV files from a company’s procurement system.  
- Renames datasets and columns using **standard P2P terminology**.  
- Creates uniform event logs with the following columns:
  - `CASE_ID` – Unique transaction identifier (e.g., PR number, PO number).  
  - `RESOURCE` – Person or system responsible for the event.  
  - `END_DATE` – Timestamp of the activity.  
  - `ACTIVITY` – Activity name (e.g., “Create Purchase Order”, “Invoice Approved”).  
  - `TYPE` – Optional activity type or category.  
- Optionally anonymizes sensitive information (suppliers, internal codes).  
- Saves final CSV files ready for process mining tools like **Celonis**, **Disco**, or **ProM**.

---

## Requirements
- **R** >= 4.0  
- `digest` package for anonymization:  

```r
install.packages("digest")
