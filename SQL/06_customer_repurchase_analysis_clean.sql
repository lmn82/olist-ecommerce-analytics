-- Olist: Customer Repeat Purchase Analysis
-- MySQL 8.0 | Run in a single MySQL session
-- Scope: delivered orders only; customer identity: customer_unique_id.
-- This is an observed-period repeat purchase rate, not a monthly retention rate.
USE olist_analysis;

-- 1. Validate join completeness and customer identity.
SELECT
    COUNT(*) AS delivered_orders,
    COUNT(DISTINCT o.order_id) AS unique_delivered_orders,
    SUM(c.customer_id IS NULL) AS unmatched_customer_rows,
    SUM(c.customer_unique_id IS NULL OR TRIM(c.customer_unique_id) = '') AS missing_unique_user_rows
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';

-- 2. Build one row per unique customer for reuse across outputs.
-- Drop only the session-scoped temporary table, not any source table.
DROP TEMPORARY TABLE IF EXISTS tmp_delivered_customer_orders;
CREATE TEMPORARY TABLE tmp_delivered_customer_orders AS
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND c.customer_unique_id IS NOT NULL
  AND TRIM(c.customer_unique_id) <> ''
GROUP BY c.customer_unique_id;

-- 3. Main KPI: share of customers with at least 2 delivered orders.
SELECT
    COUNT(*) AS purchasing_customers,
    SUM(order_count = 1) AS one_time_customers,
    SUM(order_count >= 2) AS repeat_customers,
    ROUND(100.0 * SUM(order_count >= 2) / NULLIF(COUNT(*), 0), 2) AS repeat_purchase_rate_pct,
    SUM(order_count) AS total_delivered_orders_in_scope
FROM tmp_delivered_customer_orders;

-- 4. Number of customers by delivered-order frequency.
SELECT
    order_count,
    COUNT(*) AS customer_count
FROM tmp_delivered_customer_orders
GROUP BY order_count
ORDER BY order_count;

-- 5. Optional: check customer-count reconciliation.
SELECT
    SUM(customer_count) AS customers_check,
    SUM(order_count * customer_count) AS orders_check
FROM (
    SELECT order_count, COUNT(*) AS customer_count
    FROM tmp_delivered_customer_orders
    GROUP BY order_count
) t;

-- Notes:
-- 1. customer_id can change across purchases; customer_unique_id represents the same buyer.
-- 2. Restricting to delivered orders makes the numerator/denominator consistent.
-- 3. Repeat rate is defined over the dataset's observed time window. It is NOT
--    cohort retention, 30-day repurchase, or a population-level estimate.
