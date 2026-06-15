## Hospital Patient Readmission Analysis



End-to-end healthcare data analytics project analysing 101,766 diabetic 

patient records to identify 30-day readmission risk factors and build a 

predictive model.



## Business Problem



Hospital readmissions within 30 days are costly and often preventable. 

This project analyses real US hospital data to identify which patient 

characteristics drive early readmission, helping hospitals target 

interventions where they matter most.



## Key Findings



* Overall 30-day readmission rate is 11.2% across 101,763 patient records.
* The number of prior inpatient visits is the strongest predictor of readmission patient history matters more than the current hospital stay.
* Patients readmitted within 30 days averaged more medications (16.9) than those not readmitted (15.9), indicating medication complexity is a risk signal.
* The top three risk factors are **prior inpatient visits, number of diagnoses,** 

&#x20; **and being on diabetes medication.**



## Tools & Technologies



- **SQL (MySQL)** — data ingestion, cleaning, and 8 analytical queries

- **Python** — Pandas, NumPy, scikit-learn for EDA and logistic regression

- **Power BI** — 3-page interactive dashboard with DAX measures

- **Snowflake** — cloud data warehouse with Time Travel and zero-copy clone



## Architecture



Raw CSV → MySQL (cleaning & analysis) → Python (EDA & logistic regression) → Power BI (visualisation) → Snowflake (cloud data warehouse)



A complete ETL and analytics pipeline demonstrating data engineering, 

statistical modelling, business intelligence, and cloud warehousing.



## Repository Structure



healthcare-readmission-analysis/

│

├── data/

│   ├── diabetic_data.csv           # Raw UCI dataset (101,766 records, 50 columns)

│   ├── diabetic_cleaned.csv        # Cleaned dataset (101,763 records, 47 columns)

│   ├── feature_importance.csv      # Model coefficients for BI feature chart

│   └── predictions.csv             # Model output (actual vs predicted) for BI

│

├── sql/

│   ├── 01_create_schema.sql        # DDL — table definitions & constraints

│   ├── 02_load_data.sql            # Bulk data ingestion (LOAD DATA INFILE)

│   ├── 03_cleaning.sql             # Null handling, type casting, feature derivation

│   └── 04_analysis_queries.sql     # 8 analytical queries (CTEs, window functions)

│

├── notebooks/

│   └── readmission_analysis.ipynb  # EDA, statistical analysis, ML pipeline

│

├── powerbi/

│   └── readmission_dashboard.pbix  # 3-page interactive report with DAX measures

│

├── snowflake/

│   └── snowflake_queries.sql       # Cloud DW — schema, COPY INTO, Time Travel

│

├── reports/

│   ├── eda_distributions.png       # Exploratory analysis visualisations

│   ├── model_evaluation.png        # ROC curve & feature importance

│   ├── dashboard_preview.png       # Power BI dashboard screenshot

│   └── insight_summary.pdf         # Executive findings report

│

└── README.md                       # Project documentation



## Model Performance



- Algorithm: Logistic Regression

- ROC-AUC Score: 0.643

- Precision: 51% |  Recall: 1%



## Dataset



UCI Diabetic Patient Readmission Dataset (101,766 rows, 50 columns)

Source: https://www.kaggle.com/datasets/brandao/diabetes



## Author



Bharath Sattivelou | [LinkedIn](https://linkedin.com/in/bharath20)



