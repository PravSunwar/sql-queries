-- Which vendor has the highest revenue and calculate the percentage of this revenue from the total.
-- Round revenue and percentage values to 2 decimal points.

-- 1) Using window function to solve the query:
WITH vendors_revenues AS (
  SELECT
    name AS vendor_name,
    SUM(amount_usd) AS total_revenue
  FROM transactions t
  INNER JOIN vendors v
    ON t.vendor_id = v.id
  WHERE
    amount_usd > 0
  GROUP BY 1
  ORDER BY 2 DESC
)

SELECT
  vendor_name,
  total_revenue,
  100 * total_revenue / SUM(total_revenue) OVER () AS percentage
FROM vendors_revenues

-- 2) shorted way to write this query and use window function in the same query with GROUP BY:
SELECT
  name AS vendor_name,
  ROUND(SUM(amount_usd), 2) AS total_revenue,
  ROUND(100.0 * SUM(amount_usd) / SUM(SUM(amount_usd)) OVER (), 2) AS percentage
FROM transactions t
INNER JOIN vendors v
  ON t.vendor_id = v.id
WHERE
  amount_usd > 0  
GROUP BY 1
ORDER BY 3 DESC



-- Business spending seasonality - Which month has the highest percentage of expense transactions:
-- Date_part version with a sub query:

WITH monthly_transactions AS (
  SELECT 
    DATE_PART('month', created_at) AS month_number,
    COUNT(*) total_transactions,  
    COUNT(CASE WHEN amount_usd < 0 THEN id END) expense_transactions
  FROM transactions
  GROUP BY 1
)

SELECT
  month_number,
  100.0 * expense_transactions / total_transactions AS expenses_percentage
FROM monthly_transactions
ORDER BY 2 DESC

-- Same report in a single query:
SELECT
  DATE_PART('month', created_at) AS month_number,
  100.0 * COUNT(CASE WHEN amount_usd < 0 THEN id END) / COUNT(*) AS expenses_percentage
FROM transactions
GROUP BY 1
ORDER BY 2 DESC





-- First sale date for E-commerce vendor - prepare a report with the date of the very first revenue transaction for the TOP-5 overall gross revenue vendors.
-- Window function approach adding ROW_NUMBER() & OVER(PARTITION BY):
WITH top_vendors AS (
  SELECT
    v.id AS vendor_id,
    SUM(amount_usd) gross_revenue
  FROM transactions t
  INNER JOIN vendors v
    ON t.vendor_id = v.id
  WHERE
    amount_usd > 0      
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5
), top_vendors_transactions AS (
  SELECT
    v.name AS vendor_name,
    ROW_NUMBER() OVER(PARTITION BY v.name ORDER BY t.created_at ASC) AS transaction_index,
    t.created_at AS transaction_time
  FROM transactions t
  INNER JOIN top_vendors tv
    ON t.vendor_id = tv.vendor_id
  INNER JOIN vendors v
    ON tv.vendor_id = v.id
  WHERE
    t.amount_usd > 0
)

SELECT
  vendor_name,
  transaction_time::date AS first_transaction_date
FROM top_vendors_transactions
WHERE
  transaction_index = 1
  
  -- same report using the MIN() aggregate function:
  WITH top_vendors AS (
  SELECT
    v.name AS vendor_name,
    SUM(amount_usd) gross_revenue,
    MIN(created_at)::date AS first_transaction_date
  FROM transactions t
  INNER JOIN vendors v
    ON t.vendor_id = v.id    
  WHERE
    amount_usd > 0
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5
)

SELECT
  vendor_name,
  first_transaction_date
FROM top_vendors
  
  
  

