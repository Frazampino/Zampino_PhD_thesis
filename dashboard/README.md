# Process Model Similarity Explorer

## Project Description
This dashboard is an interactive tool built with **Streamlit** for the analysis and visualization of **Process Model Matching (PMM)**.

Its primary goal is to semantically and structurally compare business process models in **BPMN** format, identifying and classifying correspondences between activities (Tasks).
---

##  Prerequisites
Before running the dashboard, ensure you have installed:

- **Python 3.8+**


## Running the Dashboard

To start the dashboard, you must run the Python script `similarity_dashboard.py` using **Streamlit**.

###  Example: Windows PowerShell
Assuming your file is in the Downloads folder:

'''powershell
PS C:\Users\fraza\Downloads> python -m streamlit run similarity_dashboard.py


## Semantic Similarity Model Used

The dashboard computes semantic similarity using the **SentenceTransformer model `all-MiniLM-L6-v2`**.

This lightweight model is fast, efficient, and well-suited for comparing short text labels such as BPMN activity names.

Code reference:
```python
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('all-MiniLM-L6-v2')
