-- (E-commerce dataset)

-- Write a query that calculates percentages of positive, negative, mixed and neutral reviews.
WITH reviews_by_type AS (
  SELECT 
    CASE 
    WHEN LOWER(feedback) SIMILAR TO'%(amazing|great|awesome|good|perfect|impressed|super)%' AND LOWER(feedback) SIMILAR TO'%(bad|terrible|horrible|disappointed|broken)%' THEN 'mixed'
    WHEN LOWER(feedback) SIMILAR TO'%(amazing|great|awesome|good|perfect|impressed|super)%' THEN 'positive'
    WHEN LOWER(feedback) SIMILAR TO'%(bad|terrible|horrible|disappointed|broken)%' THEN 'negative'  
    ELSE 'neutral'
    END AS review_type,
    COUNT(*) AS reviews_count
  FROM reviews
  GROUP BY 1
)

SELECT
  review_type, 
  ROUND(100 * reviews_count / SUM(reviews_count) OVER ()) AS percentage,   
  reviews_count
FROM reviews_by_type  
ORDER BY 2 DESC

-- Your task is to count the number of published items for each root category:
-- ⚠ Published item is a record with non-NULL published_at field.
-- ⚠ Name columns of your result set root_category_name and items_count.
SELECT
  c1.name AS root_category_name,
  COUNT(i.*) AS items_count
FROM categories c1
LEFT JOIN categories c2
  ON c1.id = c2.parent_id
LEFT JOIN categories c3
  ON c2.id = c3.parent_id
LEFT JOIN items i
  ON c3.id = i.category_id  
    AND i.published_at IS NOT NULL
WHERE 
  c1.parent_id IS NULL  
GROUP BY 1
ORDER BY 2 DESC

 -- Your task is to calculate the return rate (percentage of returned items from all items of all purchased carts) for each vendor in the E-commerce dataset.
-- ⚠ Name the result set columns vendor_id, vendor_name and return_rate. Round the return rate to 2 decimal places.
-- ⚠ refund_rate should always be a number from 0 to 100.
-- ⚠ Make sure to exclude vendors without purchases from your report.
SELECT
  v.id AS vendor_id,
  v.name AS vendor_name,  
  ROUND(100.0 * COALESCE(SUM(r.quantity), 0) / SUM(ci.quantity), 2) AS return_rate
FROM carts c
INNER JOIN purchases p
  ON p.cart_id = c.id
INNER JOIN carts_items ci
  ON c.id = ci.cart_id
INNER JOIN items i
  ON i.id = ci.item_id  
INNER JOIN vendors v
  ON i.vendor_id = v.id  
LEFT JOIN returns r
  ON ci.cart_id = r.cart_id
    AND ci.item_id = r.item_id
GROUP BY 1, 2
ORDER BY 3 DESC

-- ☝ Report the number of records and the percentage from total amount for each rating. Sort result set by values of rating_portion. ⬇
-- ☝ Round rating_portion column to 2 decimal values.
-- ⚠ Name the result set columns rating, ratings_count and rating_portion.
WITH counts AS (
  SELECT
    rating,
    COUNT(*) AS ratings_count
  FROM reviews
  GROUP BY 1
  ORDER BY 2 DESC
)

SELECT
  rating,
  ratings_count,
  ROUND(100.0 * ratings_count / SUM(ratings_count) OVER (), 2) AS rating_portion
FROM counts

-- Report the 5 products with the highest average rating:
-- ☝ Consider only products with 4 or more reviews.
-- ☝ Round avg_rating column to 2 decimal places. Order products by the average rating. ⬇
-- ⚠ Name the result set columns name, avg_rating and ratings_count.

WITH items_ratings AS (
  SELECT
    item_id,
    AVG(rating) AS avg_rating,
    COUNT(*) AS ratings_count
  FROM reviews
  GROUP BY 1
)  

SELECT
  name,
  ROUND(avg_rating, 2) AS avg_rating,
  ratings_count
FROM items_ratings r
INNER JOIN items i
  ON i.id = r.item_id
WHERE
  ratings_count > 3
ORDER BY avg_rating DESC  
LIMIT 5

-- report the 5 products with the highest average rating:
-- ☝ Consider only products with 4 or more reviews.
-- ☝ Round avg_rating column to 2 decimal places. Order products by the average rating. ⬇
-- ⚠ Name the result set columns name, avg_rating and ratings_count.

WITH items_ratings AS (
  SELECT
    item_id,
    AVG(rating) AS avg_rating,
    COUNT(*) AS ratings_count
  FROM reviews
  GROUP BY 1
)  

SELECT
  name,
  ROUND(avg_rating, 2) AS avg_rating,
  ratings_count
FROM items_ratings r
INNER JOIN items i
  ON i.id = r.item_id
WHERE
  ratings_count > 3
ORDER BY avg_rating DESC  
LIMIT 5