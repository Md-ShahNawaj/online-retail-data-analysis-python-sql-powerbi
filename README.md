# Online Retail Data Analysis (Python + SQL + Power BI)

An end-to-end data analysis project on the [Online Retail II dataset](https://archive.ics.uci.edu/dataset/502/online+retail+ii) from the UCI Machine Learning Repository. The project covers data cleaning in Python, analytical SQL queries in PostgreSQL, and an interactive Power BI dashboard — extracting actionable business insights on customer behavior, sales performance, and retention.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Key Analyses](#key-analyses)
  - [1. Data Cleaning & Preparation](#1-data-cleaning--preparation)
  - [2. KPI Queries](#2-kpi-queries)
  - [3. Cohort Analysis](#3-cohort-analysis)
  - [4. RFM Segmentation](#4-rfm-segmentation)
  - [5. Power BI Dashboard](#5-power-bi-dashboard)
- [How to Run](#how-to-run)
- [Results & Insights](#results--insights)

---

## Project Overview

This project answers key business questions for an online retail company:

- Who are the most valuable customers?
- Which customer segments are at risk of churning?
- How well does the company retain customers over time?
- What are the revenue and order trends by month, country, and product?

The pipeline goes from raw Excel data → cleaned CSV → PostgreSQL views → Power BI visuals.

---

## Dataset

| Attribute | Details |
|-----------|---------|
| **Source** | [UCI ML Repository – Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) |
| **Alternative (Cleaned)** | [Kaggle – Cleaned Dataset](https://www.kaggle.com/datasets/shahnawaj9/online-retail) |
| **Period** | December 2009 – December 2011 |
| **Size** | ~1,067,371 transactions (after combining both years) |
| **Geography** | UK-based retailer with customers across multiple countries |

**Columns:**

| Column | Description |
|--------|-------------|
| `InvoiceNo` | Invoice number (prefix `C` = cancellation) |
| `StockCode` | Product code |
| `Description` | Product name |
| `Quantity` | Units per transaction |
| `InvoiceDate` | Date and time of transaction |
| `UnitPrice` | Price per unit (GBP) |
| `CustomerID` | Unique customer identifier |
| `Country` | Customer's country |

---

## Project Structure

```
online-retail-data-analysis/
│
├── 01_data_cleaning_with_Python/
│   ├── retail_data_cleaning_and_preparation.ipynb   # Main cleaning pipeline
│   └── Queries.ipynb                                # DB import & query testing
│
├── 02_sql_scripts_in_PostgreSQL/
│   ├── kpi_test_queries.sql                         # 8 analytical KPI views
│   ├── RFM_Segmentation.sql                         # RFM scoring & segments
│   └── Cohort_Analysis.sql                          # Retention cohort views
│
├── 03_cohort_analysis/
│   ├── README.md
│   ├── Cohort_Analysis.sql
│   ├── Cohort_Analysis_on_Revenue.csv               # Output: revenue by cohort
│   └── Cohort_analysis_on_Customer_Level.csv        # Output: retention counts
│
├── 04_RFM_segmentation/
│   ├── README.md
│   ├── RFM_Segmentation.sql
│   └── rfm_final_score.csv                          # Output: all customers scored
│
├── 05_power_bi_dashboard/
│   └── Retail_analysis.pbix                         # Interactive Power BI report
│
└── README.md
```

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| **Python** (Pandas, NumPy, SQLAlchemy) | Data cleaning, preprocessing, DB ingestion |
| **PostgreSQL** | Analytical SQL queries and views |
| **Jupyter Notebook** | Exploratory analysis and pipeline documentation |
| **Power BI** | Interactive dashboard and business intelligence |

---

## Key Analyses

### 1. Data Cleaning & Preparation

**Notebook:** [`01_data_cleaning_with_Python/retail_data_cleaning_and_preparation.ipynb`](01_data_cleaning_with_Python/retail_data_cleaning_and_preparation.ipynb)

- Combined two Excel sheets (2009–2010 and 2010–2011) into a single DataFrame of **1,067,371 rows**
- Flagged cancellation invoices (prefix `C`) with an `is_cancelled` column
- Dropped rows with missing `Description` (4,382 rows removed)
- Standardized column names to lowercase snake_case
- Added `total_price` column (`quantity × unit_price`)
- Final clean dataset: **1,062,989 rows** exported to `online_retail_cleaned.csv`

**Notebook:** [`01_data_cleaning_with_Python/Queries.ipynb`](01_data_cleaning_with_Python/Queries.ipynb)

- Imported cleaned CSV into PostgreSQL using SQLAlchemy
- Created the `retail_data` table and ran validation queries

---

### 2. KPI Queries

**Script:** [`02_sql_scripts_in_PostgreSQL/kpi_test_queries.sql`](02_sql_scripts_in_PostgreSQL/kpi_test_queries.sql)

Eight SQL views covering the core business KPIs:

| View | Description |
|------|-------------|
| `total_orders_revenue` | Overall revenue, order count, and customer count |
| `yearly_revenue_order_summary` | Revenue and orders broken down by year |
| `monthly_revenue` | Monthly revenue trend with active customer counts |
| `top_customers` | Customers ranked by total spend |
| `country_summary` | Revenue and orders by country |
| `product_sales_summary` | Top-selling products by quantity and revenue |
| `segment_revenue_summary` | Revenue breakdown by RFM customer segment |
| `new_vs_returning_customers` | Monthly split of new vs. returning customers |
| `cancel_rate_summary` | Cancellation rate trend over time |

---

### 3. Cohort Analysis

**Folder:** [`03_cohort_analysis/`](03_cohort_analysis/)

Customers are grouped by their **first purchase month** (cohort). The analysis then tracks how many of those customers (and how much revenue) return in each subsequent month (Month 0 through Month 12).

Two output views:
- **Customer-level cohort** — how many customers from each cohort return month over month
- **Revenue-level cohort** — how much revenue each cohort generates in subsequent months

This reveals retention drop-off rates and identifies which acquisition periods produced the most loyal customers.

For a full methodology walkthrough, see [`03_cohort_analysis/README.md`](03_cohort_analysis/README.md).

---

### 4. RFM Segmentation

**Folder:** [`04_RFM_segmentation/`](04_RFM_segmentation/)

RFM (Recency, Frequency, Monetary) scoring assigns each customer a value on three dimensions:

| Dimension | Definition |
|-----------|-----------|
| **Recency** | Days since last purchase (lower = better) |
| **Frequency** | Number of distinct invoices |
| **Monetary** | Total spend (GBP) |

Each metric is scored 1–4 using `NTILE(4)`, producing a 3-digit RFM code (e.g., `444` = best customers). Customers are then mapped to six business segments:

| Segment | Description |
|---------|-------------|
| **Loyal** | High scores across all three metrics |
| **Active** | Regularly purchasing, engaged customers |
| **New Customers** | Recent first-time buyers |
| **Potential Churners** | Moderate risk — declining engagement |
| **Slipping Away, Cannot Lose** | Were high-value, now going quiet |
| **Churned Customer** | Low recency, frequency, and spend |

Output: [`04_RFM_segmentation/rfm_final_score.csv`](04_RFM_segmentation/rfm_final_score.csv)

For full segment definitions and scoring logic, see [`04_RFM_segmentation/README.md`](04_RFM_segmentation/README.md).

---

### 5. Power BI Dashboard

**File:** [`05_power_bi_dashboard/Retail_analysis.pbix`](05_power_bi_dashboard/Retail_analysis.pbix)

An interactive Power BI report built on top of the PostgreSQL views and CSV outputs. It brings together all analyses into a single dashboard for business stakeholder reporting.

To open: download the `.pbix` file and open it in **Power BI Desktop**.

---

## How to Run

### Prerequisites

- Python 3.8+
- PostgreSQL (any recent version)
- Power BI Desktop (for the dashboard)
- Jupyter Notebook or JupyterLab

### Steps

**1. Clone the repository**

```bash
git clone https://github.com/Md-ShahNawaj/online-retail-data-analysis-python-sql-powerbi.git
cd online-retail-data-analysis-python-sql-powerbi
```

**2. Install Python dependencies**

```bash
pip install pandas numpy openpyxl sqlalchemy psycopg2
```

**3. Download the dataset**

Download the **Online Retail II** dataset from [UCI ML Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) or use the [pre-cleaned Kaggle version](https://www.kaggle.com/datasets/shahnawaj9/online-retail).

**4. Run data cleaning**

Open and run [`01_data_cleaning_with_Python/retail_data_cleaning_and_preparation.ipynb`](01_data_cleaning_with_Python/retail_data_cleaning_and_preparation.ipynb). This produces `online_retail_cleaned.csv`.

**5. Import data into PostgreSQL**

Update the database connection string in [`01_data_cleaning_with_Python/Queries.ipynb`](01_data_cleaning_with_Python/Queries.ipynb) and run it to create the `retail_data` table.

**6. Run SQL scripts**

Execute the SQL files in PostgreSQL in this order:

```
02_sql_scripts_in_PostgreSQL/kpi_test_queries.sql
02_sql_scripts_in_PostgreSQL/RFM_Segmentation.sql
02_sql_scripts_in_PostgreSQL/Cohort_Analysis.sql
```

**7. Open the Power BI dashboard**

Open [`05_power_bi_dashboard/Retail_analysis.pbix`](05_power_bi_dashboard/Retail_analysis.pbix) in Power BI Desktop. Update the data source connection to point to your PostgreSQL instance if prompted.

---

## Results & Insights

- **1M+ transactions** cleaned and analyzed across two years of retail data
- **RFM segmentation** identifies actionable customer groups — from loyal high-spenders to at-risk churners — enabling targeted marketing campaigns
- **Cohort analysis** reveals customer retention trends over 12 months, showing how well different acquisition cohorts are retained
- **KPI views** provide a ready-to-use analytical layer in PostgreSQL, powering both ad-hoc queries and the Power BI dashboard
- **Interactive dashboard** delivers business-ready visuals for revenue trends, geographic breakdowns, product performance, and customer segments
