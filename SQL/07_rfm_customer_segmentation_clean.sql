-- Olist customer RFM segmentation | MySQL 8.0
-- Scope: delivered orders; F = distinct orders; M = sum of item prices, excluding freight.
-- R: calendar days since most recent purchase, evaluated at fixed observation date 2018-08-29.
-- Requires: orders, customers, order_items. Read-only for source tables.
-- Run the entire script in ONE MySQL Workbench connection because it uses TEMPORARY tables.
USE olist_analysis;

DROP TEMPORARY TABLE IF EXISTS tmp_rfm_orders;
CREATE TEMPORARY TABLE tmp_rfm_orders AS
SELECT
    o.order_id,
    c.customer_unique_id,
    STR_TO_DATE(NULLIF(TRIM(o.order_purchase_timestamp), ''), '%Y-%m-%d %H:%i:%s') AS purchase_ts,
    SUM(CAST(i.price AS DECIMAL(14,2))) AS order_amount
FROM orders AS o
JOIN customers AS c
  ON o.customer_id = c.customer_id
JOIN order_items AS i
  ON o.order_id COLLATE utf8mb4_unicode_ci = i.order_id COLLATE utf8mb4_unicode_ci
WHERE o.order_status = 'delivered'
  AND c.customer_unique_id IS NOT NULL
  AND TRIM(c.customer_unique_id) <> ''
GROUP BY o.order_id, c.customer_unique_id, o.order_purchase_timestamp;

-- 1. Check orders and missing parsed dates before filtering: any NULL means investigate.
SELECT
    COUNT(*) AS order_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(purchase_ts IS NULL) AS invalid_purchase_dates,
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM tmp_rfm_orders;

DROP TEMPORARY TABLE IF EXISTS tmp_rfm;
CREATE TEMPORARY TABLE tmp_rfm AS
SELECT
    customer_unique_id,
    DATEDIFF('2018-08-29', MAX(purchase_ts)) AS Recency,
    COUNT(DISTINCT order_id) AS Frequency,
    ROUND(SUM(order_amount), 2) AS Monetary
FROM tmp_rfm_orders
WHERE purchase_ts IS NOT NULL
GROUP BY customer_unique_id;

-- 2. RFM overview. Compare with original results before treating as a validated final script.
SELECT
    COUNT(*) AS customer_count,
    MIN(Recency) AS min_recency,
    MAX(Recency) AS max_recency,
    MIN(Frequency) AS min_frequency,
    MAX(Frequency) AS max_frequency,
    MIN(Monetary) AS min_monetary,
    MAX(Monetary) AS max_monetary
FROM tmp_rfm;

-- 3. Calculate median Monetary from the SAME customer population (not a hard-coded cutoff).
DROP TEMPORARY TABLE IF EXISTS tmp_rfm_cutoff;
CREATE TEMPORARY TABLE tmp_rfm_cutoff AS
SELECT AVG(Monetary) AS median_monetary
FROM (
    SELECT
        Monetary,
        ROW_NUMBER() OVER (ORDER BY Monetary, customer_unique_id) AS rn,
        COUNT(*) OVER () AS total_n
    FROM tmp_rfm
) AS ranked
WHERE rn IN (
    FLOOR((total_n + 1) / 2),
    FLOOR((total_n + 2) / 2)
);
SELECT ROUND(median_monetary, 2) AS median_monetary FROM tmp_rfm_cutoff;

-- 4. Four mutually exclusive segments, retaining the original 90-day R cutoff.
-- This 90-day rule is a heuristic for the portfolio, not an empirically optimized threshold.
SELECT
    CASE
        WHEN r.Recency <= 90 AND r.Frequency >= 2 AND r.Monetary >= c.median_monetary
          THEN 'Recent Repeat High Spend'
        WHEN r.Recency > 90 AND r.Frequency >= 2 AND r.Monetary >= c.median_monetary
          THEN 'Inactive Repeat High Spend'
        WHEN r.Frequency = 1 AND r.Monetary >= c.median_monetary
          THEN 'One-time High Spend'
        ELSE 'Other Customers'
    END AS customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(r.Monetary), 2) AS avg_monetary
FROM tmp_rfm AS r
CROSS JOIN tmp_rfm_cutoff AS c
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- 5. Segmentation coverage check.
SELECT COUNT(*) AS rfm_customers FROM tmp_rfm;
