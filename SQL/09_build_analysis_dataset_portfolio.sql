USE olist_analysis;

CREATE TABLE analysis_logistics_final_portfolio AS

WITH item_summary AS (
    SELECT
        order_id,
        COUNT(*) AS item_count,
        ROUND(SUM(CAST(price AS DECIMAL(12,2))), 2)
            AS order_amount
    FROM order_items
    GROUP BY order_id
)

SELECT
    o.order_id,

    DATE(STR_TO_DATE(
        o.order_purchase_timestamp,
        '%Y-%m-%d %H:%i:%s'
    )) AS purchase_date,

    c.customer_state,

    DATEDIFF(
        STR_TO_DATE(
            o.order_delivered_customer_date,
            '%Y-%m-%d %H:%i:%s'
        ),
        STR_TO_DATE(
            o.order_estimated_delivery_date,
            '%Y-%m-%d %H:%i:%s'
        )
    ) AS delay_days,

    CASE
        WHEN DATEDIFF(
            STR_TO_DATE(o.order_delivered_customer_date,
                        '%Y-%m-%d %H:%i:%s'),
            STR_TO_DATE(o.order_estimated_delivery_date,
                        '%Y-%m-%d %H:%i:%s')
        ) > 0 THEN 1
        ELSE 0
    END AS is_late,

    CAST(r.review_score AS UNSIGNED) AS review_score,

    CASE
        WHEN CAST(r.review_score AS UNSIGNED) <= 2
        THEN 1 ELSE 0
    END AS is_bad_review,

    i.item_count,
    i.order_amount

FROM orders AS o

JOIN customers AS c
    ON o.customer_id = c.customer_id

JOIN order_reviews_clean_portfolio AS r
    ON o.order_id COLLATE utf8mb4_unicode_ci
     = r.order_id COLLATE utf8mb4_unicode_ci

JOIN item_summary AS i
    ON o.order_id COLLATE utf8mb4_unicode_ci
     = i.order_id COLLATE utf8mb4_unicode_ci

WHERE o.order_status = 'delivered'

  AND STR_TO_DATE(
      NULLIF(TRIM(o.order_purchase_timestamp), ''),
      '%Y-%m-%d %H:%i:%s'
  ) IS NOT NULL

  AND STR_TO_DATE(
      NULLIF(TRIM(o.order_delivered_customer_date), ''),
      '%Y-%m-%d %H:%i:%s'
  ) IS NOT NULL

  AND STR_TO_DATE(
      NULLIF(TRIM(o.order_estimated_delivery_date), ''),
      '%Y-%m-%d %H:%i:%s'
  ) IS NOT NULL

  AND CAST(r.review_score AS UNSIGNED) BETWEEN 1 AND 5;
  
SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders,

    SUM(item_count IS NULL) AS missing_items,
    SUM(order_amount IS NULL) AS missing_amount,

    ROUND(AVG(order_amount), 2) AS avg_amount,
    ROUND(100 * AVG(is_late), 2) AS late_rate,
    ROUND(100 * AVG(is_bad_review), 2) AS bad_review_rate

FROM analysis_logistics_final_portfolio;

USE olist_analysis;

SELECT
    COUNT(*) AS compared_orders,

    SUM(CASE
        WHEN old.order_id IS NULL THEN 1 ELSE 0
    END) AS new_only_orders,

    SUM(CASE
        WHEN NOT (old.purchase_date <=> new.purchase_date)
          OR NOT (old.customer_state <=> new.customer_state)
          OR NOT (old.delay_days <=> new.delay_days)
          OR NOT (old.is_late <=> new.is_late)
          OR NOT (old.review_score <=> new.review_score)
          OR NOT (old.is_bad_review <=> new.is_bad_review)
          OR NOT (old.item_count <=> new.item_count)
          OR NOT (old.order_amount <=> new.order_amount)
        THEN 1 ELSE 0
    END) AS different_orders

FROM analysis_logistics_final_portfolio AS new

LEFT JOIN analysis_logistics_final AS old
    ON new.order_id COLLATE utf8mb4_unicode_ci
     = old.order_id COLLATE utf8mb4_unicode_ci;
     
SELECT
    COUNT(*) AS old_only_orders
FROM analysis_logistics_final AS old
LEFT JOIN analysis_logistics_final_portfolio AS new
    ON old.order_id COLLATE utf8mb4_unicode_ci
     = new.order_id COLLATE utf8mb4_unicode_ci
WHERE new.order_id IS NULL;