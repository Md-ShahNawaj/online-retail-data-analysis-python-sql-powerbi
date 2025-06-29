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
