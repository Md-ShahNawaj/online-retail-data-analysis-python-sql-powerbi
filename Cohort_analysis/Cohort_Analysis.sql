-- Cohort Analysis/Customer Retention Analysis on Customer Level
CREATE OR REPLACE VIEW cohort_analysis_on_customer_level AS
with CTE1 as(
SELECT 
    invoice, 
    customer_id as CUSTOMERID,
    invoicedate AS INVOICEDATE,
    DATE_TRUNC('month', invoicedate::timestamp) AS purchase_month,
    DATE_TRUNC('month', MIN(invoicedate::timestamp) OVER (PARTITION BY customer_id)) AS FIRST_PURCHASE_MONTH,
    ROUND(total_price::numeric, 0) AS revenue
FROM retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
),
CTE2 AS(
SELECT 
	CUSTOMERID, 
	FIRST_PURCHASE_MONTH,
	 CONCAT(
    'Month_',
    DATE_PART('month', AGE(purchase_month, first_purchase_month)) +
    (DATE_PART('year', AGE(purchase_month, first_purchase_month)) * 12)
  ) AS cohort_month
FROM CTE1
)
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
--
SELECT * from cohort_analysis_on_customer_level Limit 10;
--




-- Cohort Analysis on Revenue
CREATE OR REPLACE VIEW cohort_analysis_on_revenue AS
with CTE1 as(
SELECT 
    invoice, 
    customer_id as CUSTOMERID,
    invoicedate AS INVOICEDATE,
    DATE_TRUNC('month', invoicedate::timestamp) AS purchase_month,
    DATE_TRUNC('month', MIN(invoicedate::timestamp) OVER (PARTITION BY customer_id)) AS FIRST_PURCHASE_MONTH,
    ROUND(total_price::numeric, 0) AS REVENUE
FROM retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
),
CTE2 AS(
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
--
SELECT * from cohort_analysis_on_revenue Limit 10;