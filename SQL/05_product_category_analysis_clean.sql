-- Olist product-category sales contribution | MySQL 8.0
-- Source: 05_product_category_analysis.sql (refactored)
-- Scope: delivered orders only; monetary metric = SUM(order_items.price), excluding freight.
-- Each item row represents one order item, not necessarily a unique order.
USE olist_analysis;

-- A. Quality check: match order item product IDs to products.
SELECT
    COUNT(*) AS item_rows,
    SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END) AS unmatched_product_rows,
    SUM(CASE WHEN p.product_id IS NOT NULL
              AND (p.product_category_name IS NULL OR TRIM(p.product_category_name) = '')
             THEN 1 ELSE 0 END) AS missing_category_rows
FROM order_items AS i
LEFT JOIN products AS p
  ON i.product_id COLLATE utf8mb4_unicode_ci
   = p.product_id COLLATE utf8mb4_unicode_ci;

-- B. Reusable category-level dataset. Drop only the temporary table in the current session.
DROP TEMPORARY TABLE IF EXISTS tmp_category_sales;
CREATE TEMPORARY TABLE tmp_category_sales AS
SELECT
    COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'Unknown') AS category,
    COUNT(*) AS item_count,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(CAST(i.price AS DECIMAL(16,2))) AS sales_amount
FROM order_items AS i
JOIN orders AS o ON i.order_id = o.order_id
LEFT JOIN products AS p
  ON i.product_id COLLATE utf8mb4_unicode_ci
   = p.product_id COLLATE utf8mb4_unicode_ci
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'Unknown');

-- C. Top 10 categories by product sales amount.
SELECT category, item_count, order_count, ROUND(sales_amount, 2) AS sales_amount
FROM tmp_category_sales
ORDER BY sales_amount DESC, category
LIMIT 10;

-- D. Contribution and cumulative contribution (full category list).
SELECT
    category,
    item_count,
    order_count,
    ROUND(sales_amount, 2) AS sales_amount,
    ROUND(100.0 * sales_amount / NULLIF(SUM(sales_amount) OVER (), 0), 2) AS sales_pct,
    ROUND(100.0 * SUM(sales_amount) OVER (
        ORDER BY sales_amount DESC, category
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / NULLIF(SUM(sales_amount) OVER (), 0), 2) AS cumulative_pct
FROM tmp_category_sales
ORDER BY sales_amount DESC, category;

-- E. Top-10 cumulative contribution measured against ALL categories (not just top ten).
SELECT
    category,
    ROUND(sales_amount, 2) AS sales_amount,
    ROUND(100.0 * SUM(sales_amount) OVER (
        ORDER BY sales_amount DESC, category
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) / NULLIF(SUM(sales_amount) OVER (), 0), 2) AS cumulative_pct
FROM tmp_category_sales
ORDER BY sales_amount DESC, category
LIMIT 10;

-- F. First category ranking at which cumulative contribution reaches 80%.
-- Use unrounded share for filtering to prevent threshold errors near 80%.
WITH ranked AS (
    SELECT
        category,
        sales_amount,
        ROW_NUMBER() OVER (ORDER BY sales_amount DESC, category) AS category_rank,
        SUM(sales_amount) OVER (
            ORDER BY sales_amount DESC, category
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) / NULLIF(SUM(sales_amount) OVER (), 0) AS cumulative_share
    FROM tmp_category_sales
)
SELECT
    category_rank,
    category,
    ROUND(sales_amount, 2) AS sales_amount,
    ROUND(cumulative_share * 100, 2) AS cumulative_pct
FROM ranked
WHERE cumulative_share >= 0.80
ORDER BY category_rank
LIMIT 1;
