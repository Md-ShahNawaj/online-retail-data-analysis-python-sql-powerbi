-- Total Orders & Revenue
CREATE OR REPLACE VIEW total_orders_revenue AS
SELECT
  COUNT(DISTINCT invoice) AS total_orders,
  ROUND(SUM(total_price::numeric), 0) AS total_revenue
FROM retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL;
--
SELECT * from total_orders_revenue;
--
-- Yearly Revenue and Order Summary 
CREATE OR REPLACE VIEW yearly_revenue_order_summary AS
SELECT
  EXTRACT(YEAR FROM invoicedate::timestamp) AS order_year,
  COUNT(DISTINCT invoice) AS total_orders,
  ROUND(SUM(total_price::numeric), 0) AS total_revenue
FROM retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
GROUP BY order_year
ORDER BY order_year;
--
SELECT * from yearly_revenue_order_summary;
--

--Monthly Revenue Trend
CREATE OR REPLACE VIEW monthly_revenue AS
SELECT 
  DATE_TRUNC('month', invoicedate::timestamp) AS month,
  ROUND(SUM(total_price::numeric),0) AS total_revenue,
  COUNT(DISTINCT customer_id) AS active_customers,
  COUNT(DISTINCT invoice) AS total_orders
FROM retail_data
WHERE is_cancelled = FALSE AND  customer_id IS NOT NULL
GROUP BY 1
ORDER BY 1;
--
select * from monthly_revenue LIMIT 10;
--

--Top Customers View
CREATE OR REPLACE VIEW top_customers AS
SELECT 
  customer_id,
  ROUND(SUM(total_price::numeric), 0) AS total_spent,
  COUNT(DISTINCT invoice) AS total_orders
FROM retail_data
WHERE is_cancelled = FALSE AND  customer_id IS NOT NULL
GROUP BY customer_id
ORDER BY total_spent DESC;
--
select * from top_customers LIMIT 10;
--



--Country Summary
CREATE OR REPLACE VIEW country_summary AS
SELECT
  country,
  COUNT(DISTINCT customer_id) AS total_customers,
  COUNT(DISTINCT invoice) AS total_orders,
  ROUND(SUM(total_price::numeric), 2) AS total_revenue
FROM retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
GROUP BY country
ORDER BY total_revenue DESC;
--
select * from country_summary;
--


--Product Sales Summary
CREATE OR REPLACE VIEW product_sales_summary AS
SELECT 
  stockcode,
  description,
  SUM(quantity) AS total_units_sold,
  ROUND(SUM(total_price::numeric), 2) AS total_revenue
FROM retail_data
WHERE is_cancelled = FALSE
GROUP BY stockcode, description
ORDER BY total_revenue DESC;
--
select * from product_sales_summary Limit 10;
--

--Segment Revenue Summary
CREATE OR REPLACE VIEW segment_revenue_summary AS
SELECT
  r.customer_segment,
  COUNT(DISTINCT r.customer_id) AS customer_count,
  ROUND(SUM(rd.total_price::numeric), 0) AS total_revenue
FROM rfm_segment r
JOIN retail_data rd ON r.customer_id = rd.customer_id
WHERE rd.is_cancelled = FALSE AND rd.customer_id IS NOT NULL
GROUP BY r.customer_segment
ORDER BY total_revenue DESC;
--
select * from segment_revenue_summary LIMIT 10;
--

-- New vs. Returning Customers by Month
CREATE OR REPLACE VIEW new_vs_returning_customers AS
WITH first_purchase AS (
  SELECT customer_id, MIN(invoicedate) AS first_order
  FROM retail_data
  WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
  GROUP BY customer_id
)
SELECT 
  DATE_TRUNC('month', r.invoicedate::timestamp) AS order_month,
  COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', r.invoicedate::timestamp) = DATE_TRUNC('month', f.first_order::timestamp) THEN r.customer_id
  END) AS new_customers,
  COUNT(DISTINCT CASE WHEN DATE_TRUNC('month', r.invoicedate::timestamp) > DATE_TRUNC('month', f.first_order::timestamp) THEN r.customer_id
  END) AS returning_customers
FROM retail_data r
JOIN first_purchase f ON r.customer_id = f.customer_id
WHERE r.is_cancelled = FALSE AND r.customer_id IS NOT NULL
GROUP BY order_month
ORDER BY order_month;
--
select * from new_vs_returning_customers LIMIT 10;
--

--Cancel Rate Summary
CREATE OR REPLACE VIEW cancel_rate_summary AS
SELECT 
  DATE_TRUNC('month', invoicedate::timestamp) AS month,
  COUNT(*) AS total_orders,
  COUNT(*) FILTER (WHERE is_cancelled = TRUE) AS cancelled_orders,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE is_cancelled = TRUE) / COUNT(*),
    2
  ) AS cancel_rate_percentage
FROM retail_data
WHERE customer_id IS NOT NULL
GROUP BY month
ORDER BY month;
--
select * from cancel_rate_summary LIMIT 10;
--