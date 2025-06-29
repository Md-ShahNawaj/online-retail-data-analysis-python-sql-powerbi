# RFM Segmentation

RFM Segmentation (Recency, Frequency, Monetary) is a marketing analysis technique used to categorize customers based on their purchase history. By analyzing how recently, how often, and how much a customer spends, businesses can identify high-value customers, tailor marketing strategies, and improve customer retention.

## Why We Should Go Through This Process

RFM segmentation calculates Recency, Frequency, and Monetary scores for each customer to better understand their behavior. Using these scores, customers are grouped into meaningful segments such as Churned Customers, Slipping Away (High Risk), New Customers, Potential Churners, Active, and Loyal. The accompanying SQL script performs this segmentation, enabling more targeted marketing and customer retention strategies.

## Dataset Description

| Column Name   | Description |
|---------------|-------------|
| `invoice` | Invoice number for the transaction |
| `stockcode` | Unique identifier for the product |
| `description` | Name or description of the product |
| `quantity` | Number of items purchased in the transaction |
| `invoicedate` | Date and time when the invoice was generated |
| `price` | Unit price of the product |
| `customer_id` | Unique ID representing the customer |
| `country` | Country of the customer |
| `is_cancelled` | Boolean indicating if the transaction was cancelled |
| `total_price` | Total transaction amount (quantity × price) |


## Analysis

1. Initial Calculation (RFM values)   
 This step aggregates data per customer to calculate:
 - **Recency**: Days since the most recent purchase  
 - **Frequency**: Unique number of purchases (invoices)  
 - **Monetary**: Total spend by customer

### SQL Query

```sql
WITH RFM_INITIAL_CALC AS (
  SELECT
    customer_id,
    ROUND(SUM(total_price::numeric), 0) AS MonetaryValue,
    COUNT(DISTINCT invoice) AS Frequency,
    DATE_PART('day', (
        SELECT MAX(invoicedate)::timestamp FROM retail_data
    ) - MAX(invoicedate)::timestamp) AS Recency
  FROM retail_data
  WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
  GROUP BY customer_id
),
```
### Output:
| customer\_id | monetaryvalue | frequency | recency |
| ------------ | ------------- | --------- | ------- |
| 12346        | 77556         | 12        | 325     |
| 12347        | 5633          | 8         | 1       |
| 12348        | 2019          | 5         | 74      |
| 12349        | 4429          | 4         | 18      |
| 12350        | 334           | 1         | 309     |
| 12351        | 301           | 1         | 374     |
| ---          | ---           | ---       | ---     | 

## 2. Scoring Using NTILE (Quartiles)

Each RFM metric is scored from 1 to 4 using `NTILE(4)` to assign quartile-based ranks:

- **Recency** is sorted in **descending** order → lower values (more recent) get higher scores  
- **Frequency** and **MonetaryValue** are sorted in **ascending** order → higher values get higher scores

```sql
RFM_SCORE_CALC AS (
  SELECT 
    C.*,
    NTILE(4) OVER (ORDER BY C.Recency DESC) AS RFM_RECENCY_SCORE,
    NTILE(4) OVER (ORDER BY C.Frequency ASC) AS RFM_FREQUENCY_SCORE,
    NTILE(4) OVER (ORDER BY C.MonetaryValue ASC) AS RFM_MONETARY_SCORE
  FROM RFM_INITIAL_CALC AS C
),
```
### Output:
| customer\_id | monetaryvalue | frequency | recency | rfm\_recency\_score | rfm\_frequency\_score | rfm\_monetary\_score |
| ------------ | ------------- | --------- | ------- | ------------------- | --------------------- | -------------------- |
| 17592        | 148           | 1         | 738     | 1                   | 1                     | 1                    |
| 12366        | 141           | 1         | 738     | 1                   | 1                     | 1                    |
| 17108        | 110           | 1         | 737     | 1                   | 1                     | 1                    |
| 14654        | 247           | 2         | 737     | 1                   | 1                     | 1                    |
| 15833        | 80            | 1         | 737     | 1                   | 1                     | 1                    |
| 13526        | 1182          | 2         | 737     | 1                   | 2                     | 3                    |
| ---          | ---           | ---       | ---     | ---                 | ---                   | ---                  |


## 3. RFM Code and Segment Mapping

A 3-digit RFM code (e.g., `444`, `123`) is generated for each customer by concatenating their Recency, Frequency, and Monetary scores.  
In addition, a total RFM score is calculated by summing these three values. These codes help in identifying patterns of customer behavior.

```sql
RFM_Seg AS (
  SELECT
    R.customer_id,
    (R.RFM_RECENCY_SCORE + R.RFM_FREQUENCY_SCORE + R.RFM_MONETARY_SCORE) AS TOTAL_RFM_SCORE,
    CONCAT(
      '', R.RFM_RECENCY_SCORE::text, R.RFM_FREQUENCY_SCORE::text, R.RFM_MONETARY_SCORE::text
    ) AS RFM_CATEGORY_COMBINATION
  FROM RFM_SCORE_CALC AS R
),

```
### Output: RFM Code and Total Score

| customer_id | total_rfm_score | rfm_category_combination |
|-------------|------------------|---------------------------|
| 17592       | 3                | 111                       |
| 12636       | 3                | 111                       |
| 17818       | 3                | 111                       |
| 14654       | 3                | 111                       |
| 15833       | 3                | 111                       |
| 13526       | 6                | 123                       |
| ---         | ---              | ---                       |



## 4. Final Segmentation

Based on the RFM code combinations, customers are classified into meaningful segments such as:
- **Churned Customers**
- **Slipping Away (High Risk)**
- **New Customers**
- **Loyal**
- **Potential Churners**
- **Active**
  
These segments allow businesses to tailor marketing strategies, improve retention, and prioritize high-value customer groups.
```sql
SELECT
  *,
  CASE
    WHEN rfm_category_combination IN ('111', '112', '121','123', '132', '211', '212', '114', '141')
      THEN 'CHURNED CUSTOMER'
    WHEN rfm_category_combination IN ('133', '134', '143', '244', '344', '343', '144')
      THEN 'SLIPPING AWAY, CANNOT LOSE'
    WHEN rfm_category_combination IN ('311', '411','421','331')
      THEN 'NEW CUSTOMERS'
    WHEN rfm_category_combination IN ('222', '231', '221', '223', '233', '322')
      THEN 'POTENTIAL CHURNERS'
    WHEN rfm_category_combination IN ('323', '333', '321', '341', '422', '332', '432')
      THEN 'ACTIVE'
    WHEN rfm_category_combination IN ('433', '434', '443', '444')
      THEN 'LOYAL'
    ELSE 'CANNOT BE DEFINED'
  END AS customer_segment
FROM RFM_seg
ORDER BY 1 DESC;
```
### Final Output: Customer Segments

| customer_id | total_rfm_score | rfm_category_combination | customer_segment            |
|-------------|------------------|---------------------------|-----------------------------|
| 18287       | 11               | 344                       | SLIPPING AWAY, CANNOT LOSE  |
| 18286       | 6                | 123                       | CHURNED CUSTOMER            |
| 18285       | 4                | 112                       | CHURNED CUSTOMER            |
| 18284       | 4                | 112                       | CHURNED CUSTOMER            |
| 18283       | 12               | 444                       | LOYAL                       |
| 18282       | 7                | 421                       | NEW CUSTOMERS               |
| 18281       | 6                | 221                       | POTENTIAL CHURNERS          |
| 18280       | 6                | 222                       | POTENTIAL CHURNERS          |
| ---         | ---              | ---                       | ---                         |


## Conclusion

RFM segmentation provides a powerful framework to understand customer behavior and value. By assigning scores based on Recency, Frequency, and Monetary metrics, we can categorize customers into actionable segments such as **Loyal**, **New**, **Churned**, or **At Risk**.

This segmentation allows businesses to:
- Personalize marketing strategies
- Improve customer retention
- Focus on high-value customer groups
- Reactivate slipping or inactive customers

With this SQL-driven approach, RFM analysis becomes scalable and easy to integrate into any data pipeline or CRM strategy.

📄 [View Full SQL Script](./RFM_segemtation/RFM_Segmentation.sql)
