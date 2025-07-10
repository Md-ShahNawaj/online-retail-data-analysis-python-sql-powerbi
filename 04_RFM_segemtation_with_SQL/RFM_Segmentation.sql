-- RFM SEGMENTATION: SEGMENTING YOUR CUSTOMER BASEN ON RECENCY (R), FREQUENCY (F), AND MONETARY (M) SCORES

CREATE OR REPLACE VIEW RFM_SEGMENT AS 
WITH RFM_INITIAL_CALC AS (
SELECT
    customer_id,
    ROUND(SUM(total_price::numeric),0) AS MonetaryValue,
    COUNT(DISTINCT invoice) AS Frequency,
	DATE_PART('day', (
        SELECT MAX(invoicedate)::timestamp FROM retail_data
    ) - MAX(invoicedate)::timestamp) AS Recency
From retail_data
WHERE is_cancelled = FALSE AND customer_id IS NOT NULL
GROUP BY customer_id
),
RFM_SCORE_CALC AS (
SELECT 
	C.*,
	NTILE(4) OVER (ORDER BY C.Recency DESC) AS RFM_RECENCY_SCORE,
	NTILE(4) OVER (ORDER BY C.Frequency ASC) AS RFM_FREQUENCY_SCORE,
	NTILE(4) OVER (ORDER BY C.MonetaryValue ASC) AS RFM_MONETARY_SCORE
FROM 
RFM_INITIAL_CALC AS C
),
RFM_Seg AS (
SELECT
    R.customer_id,
    (R.RFM_RECENCY_SCORE + R.RFM_FREQUENCY_SCORE + R.RFM_MONETARY_SCORE) AS TOTAL_RFM_SCORE,
    CONCAT(
		'', R.RFM_RECENCY_SCORE::text, R.RFM_FREQUENCY_SCORE::text, R.RFM_MONETARY_SCORE::text
    ) AS RFM_CATEGORY_COMBINATION
FROM RFM_SCORE_CALC AS R
)
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
--
SELECT  * FROM RFM_SEGMENT 
ORDER BY 1 DESC;
--