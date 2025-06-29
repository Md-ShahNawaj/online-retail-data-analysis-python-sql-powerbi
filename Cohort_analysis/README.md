# Cohort Analysis (Customer Retention)

Cohort analysis is a powerful technique used to understand customer behavior over time by grouping users based on their acquisition date (cohort) and tracking their activity in subsequent time periods. This helps businesses evaluate retention, engagement, and lifecycle value.

---

## Why Cohort Analysis Matters

By analyzing how different customer cohorts behave month over month, businesses can:
- Track user retention and churn
- Evaluate the effectiveness of onboarding or campaigns
- Identify high-performing or underperforming acquisition periods

---

## Dataset Description

| Column Name   | Description |
|---------------|-------------|
| `invoice` | Invoice number for the transaction |
| `customer_id` | Unique ID representing the customer |
| `invoicedate` | Date and time when the invoice was generated |
| `total_price` | Total transaction value (quantity × price) |
| `is_cancelled` | Boolean indicating if the transaction was canceled |

---

## Analysis Steps

### 1. Assigning Cohorts

In this step, we extract each customer's **first purchase month** and label each transaction with a **purchase month** and **cohort month**.

```sql
WITH CTE1 AS (
  SELECT 
    invoice, 
    customer_id AS CUSTOMERID,
    invoicedate AS INVOICEDATE,
    DATE_TRUNC('month', invoicedate::timestamp) AS purchase_month,
    DATE_TRUNC('month', MIN(invoicedate::timestamp) OVER (PARTITION BY customer_id)) AS FIRST_PURCHASE_MONTH,
    ROUND(total_price::numeric, 0) AS revenue
  FROM retail_data
  WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
),
```

### 2. Calculating Cohort Age (Month_0, Month_1, ...)

We compute the cohort age in months by calculating the difference between purchase and first purchase month.

```sql
CTE2 AS (
  SELECT 
    CUSTOMERID, 
    FIRST_PURCHASE_MONTH,
    CONCAT(
      'Month_',
      DATE_PART('month', AGE(purchase_month, first_purchase_month)) +
      (DATE_PART('year', AGE(purchase_month, first_purchase_month)) * 12)
    ) AS cohort_month
  FROM CTE1
),

```

### 3. Cohort Retention Table

Finally, we pivot the data to show how many customers from each cohort remained active over each month.

```sql
SELECT 
  FIRST_PURCHASE_MONTH AS Cohort,
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_0' THEN CUSTOMERID ELSE NULL END) AS "Month_0",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_1' THEN CUSTOMERID ELSE NULL END) AS "Month_1",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_2' THEN CUSTOMERID ELSE NULL END) AS "Month_2",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_3' THEN CUSTOMERID ELSE NULL END) AS "Month_3",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_4' THEN CUSTOMERID ELSE NULL END) AS "Month_4",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_5' THEN CUSTOMERID ELSE NULL END) AS "Month_5",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_6' THEN CUSTOMERID ELSE NULL END) AS "Month_6",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_7' THEN CUSTOMERID ELSE NULL END) AS "Month_7",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_8' THEN CUSTOMERID ELSE NULL END) AS "Month_8",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_9' THEN CUSTOMERID ELSE NULL END) AS "Month_9",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_10' THEN CUSTOMERID ELSE NULL END) AS "Month_10",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_11' THEN CUSTOMERID ELSE NULL END) AS "Month_11",
  COUNT(DISTINCT CASE WHEN COHORT_MONTH = 'Month_12' THEN CUSTOMERID ELSE NULL END) AS "Month_12"
FROM CTE2
GROUP BY Cohort
ORDER BY Cohort;
```

### Output: Cohort Analysis (First 6 Cohorts)

| Cohort     | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|-----------|-----------|-----------|
| 1/12/2009  | 955     | 337     | 319     | 406     | 363     | 343     | 360     | 327     | 321     | 346     | 403       | 473       | 359       |
| 1/01/2010  | 383     | 79      | 119     | 117     | 101     | 115     | 99      | 88      | 107     | 122     | 116       | 66        | 85        |
| 1/02/2010  | 376     | 89      | 84      | 109     | 92      | 75      | 72      | 107     | 95      | 103     | 43        | 47        | 57        |
| 1/03/2010  | 443     | 84      | 102     | 107     | 103     | 90      | 109     | 134     | 122     | 48      | 51        | 63        | 89        |
| 1/04/2010  | 294     | 57      | 57      | 48      | 54      | 66      | 81      | 77      | 31      | 32      | 22        | 41        | 41        |
| 1/05/2010  | 254     | 40      | 43      | 44      | 65      | 65      | 54      | 32      | 15      | 21      | 29        | 34        | 39        |
| ---        | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---       | ---       | ---       |





## Cohort Analysis on Revenue

While cohort analysis based on customer count tells us *how many* users return over time, revenue-based cohort analysis tells us *how valuable* those returning users are.

This version calculates the **total revenue** generated by each monthly cohort across their lifecycle (Month_0 to Month_12).

### SQL Query

```sql
-- Cohort Analysis on Revenue
CREATE OR REPLACE VIEW cohort_analysis_on_revenue AS
WITH CTE1 AS (
  SELECT 
    invoice, 
    customer_id AS CUSTOMERID,
    invoicedate AS INVOICEDATE,
    DATE_TRUNC('month', invoicedate::timestamp) AS purchase_month,
    DATE_TRUNC('month', MIN(invoicedate::timestamp) OVER (PARTITION BY customer_id)) AS FIRST_PURCHASE_MONTH,
    ROUND(total_price::numeric, 0) AS REVENUE
  FROM retail_data
  WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
),
CTE2 AS (
  SELECT 
    CUSTOMERID, 
    FIRST_PURCHASE_MONTH,
    CONCAT(
      'Month_',
      DATE_PART('month', AGE(purchase_month, first_purchase_month)) +
      (DATE_PART('year', AGE(purchase_month, first_purchase_month)) * 12)
    ) AS cohort_month,
    REVENUE
  FROM CTE1
)
SELECT 
  FIRST_PURCHASE_MONTH AS Cohort,
  SUM(CASE WHEN COHORT_MONTH = 'Month_0' THEN REVENUE ELSE 0 END) AS Month_0,
  SUM(CASE WHEN COHORT_MONTH = 'Month_1' THEN REVENUE ELSE 0 END) AS Month_1,
  SUM(CASE WHEN COHORT_MONTH = 'Month_2' THEN REVENUE ELSE 0 END) AS Month_2,
  SUM(CASE WHEN COHORT_MONTH = 'Month_3' THEN REVENUE ELSE 0 END) AS Month_3,
  SUM(CASE WHEN COHORT_MONTH = 'Month_4' THEN REVENUE ELSE 0 END) AS Month_4,
  SUM(CASE WHEN COHORT_MONTH = 'Month_5' THEN REVENUE ELSE 0 END) AS Month_5,
  SUM(CASE WHEN COHORT_MONTH = 'Month_6' THEN REVENUE ELSE 0 END) AS Month_6,
  SUM(CASE WHEN COHORT_MONTH = 'Month_7' THEN REVENUE ELSE 0 END) AS Month_7,
  SUM(CASE WHEN COHORT_MONTH = 'Month_8' THEN REVENUE ELSE 0 END) AS Month_8,
  SUM(CASE WHEN COHORT_MONTH = 'Month_9' THEN REVENUE ELSE 0 END) AS Month_9,
  SUM(CASE WHEN COHORT_MONTH = 'Month_10' THEN REVENUE ELSE 0 END) AS Month_10,
  SUM(CASE WHEN COHORT_MONTH = 'Month_11' THEN REVENUE ELSE 0 END) AS Month_11,
  SUM(CASE WHEN COHORT_MONTH = 'Month_12' THEN REVENUE ELSE 0 END) AS Month_12
FROM CTE2
GROUP BY Cohort
ORDER BY Cohort;
```

### Output: Revenue-Based Cohort Analysis

| Cohort     | Month_0 | Month_1 | Month_2 | Month_3 | Month_4 | Month_5 | Month_6 | Month_7 | Month_8 | Month_9 | Month_10 | Month_11 | Month_12 |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|-----------|-----------|-----------|
| 1/12/2009  | 689302  | 396642  | 297058  | 297805  | 380860  | 307988  | 306976  | 303865  | 314480  | 333399  | 393736    | 462893    | 530992    |
| 1/01/2010  | 162751  | 39287   | 51398   | 57972   | 59903   | 64111   | 52341   | 48436   | 60817   | 75052   | 72787     | 62202     | 43012     |
| 1/02/2010  | 171367  | 33561   | 55071   | 53658   | 44403   | 39941   | 40346   | 51605   | 53290   | 55224   | 36836     | 19298     | 27939     |
| 1/03/2010  | 236584  | 50210   | 52203   | 63150   | 59569   | 56594   | 65880   | 81967   | 77163   | 35384   | 24874     | 30271     | 43877     |
| 1/04/2010  | 125729  | 19120   | 20818   | 30213   | 22416   | 30657   | 35409   | 32919   | 14500   | 17788   | 6555      | 17107     | 21506     |
| 1/05/2010  | 111352  | 13745   | 14240   | 12903   | 16903   | 48761   | 23518   | 13842   | 5909    | 7286    | 9329      | 13259     | 17492     |
| ---        | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---     | ---       | ---       | ---       |
