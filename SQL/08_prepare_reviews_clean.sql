-- 08. Build a one-review-per-order staging table from imported order_reviews.
-- Based on the review deduplication section of 08_logistics_satisfaction_analysis.sql.
-- MySQL 8.0. Run in a TEST database first.
-- IMPORTANT: Creates a NEW table named order_reviews_clean_portfolio.
-- It never drops, renames, or overwrites order_reviews or order_reviews_clean.
-- If order_reviews_clean_portfolio already exists, CREATE TABLE will stop with an error.

USE olist_analysis;

-- 1. Baseline counts before deduplication
SELECT COUNT(*) AS review_rows,
       COUNT(DISTINCT order_id) AS reviewed_orders,
       COUNT(*) - COUNT(DISTINCT order_id) AS extra_review_rows
FROM order_reviews;

-- 2. Review deduplication rule (same rule used by the existing analysis):
--    keep the latest review_answer_timestamp per order;
--    break ties deterministically with review_id descending.
--    Original import stores timestamps and review_score as TEXT.
CREATE TABLE order_reviews_clean_portfolio AS
WITH review_ranked AS (
    SELECT
        order_id,
        review_id,
        review_score,
        review_answer_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY
                STR_TO_DATE(
                    NULLIF(TRIM(review_answer_timestamp), ''),
                    '%Y-%m-%d %H:%i:%s'
                ) DESC,
                review_id DESC
        ) AS rn
    FROM order_reviews
)
SELECT order_id, review_id, review_score, review_answer_timestamp
FROM review_ranked
WHERE rn = 1;

-- 3. Convert text IDs and review score into appropriate types for validation/indexing.
ALTER TABLE order_reviews_clean_portfolio
    MODIFY COLUMN order_id VARCHAR(32)
        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
    MODIFY COLUMN review_id VARCHAR(32),
    MODIFY COLUMN review_score TINYINT;

-- 4. Enforce order-level uniqueness
CREATE UNIQUE INDEX idx_review_order_id_portfolio
    ON order_reviews_clean_portfolio(order_id);

-- 5. Checks: unique orders should match the raw count of distinct order_id.
SELECT COUNT(*) AS cleaned_rows,
       COUNT(DISTINCT order_id) AS unique_orders,
       MIN(review_score) AS min_score,
       MAX(review_score) AS max_score,
       SUM(review_score IS NULL) AS null_scores
FROM order_reviews_clean_portfolio;

-- Optional comparison with the existing verified table (if it exists):
-- SELECT COUNT(*) FROM order_reviews_clean;
-- SELECT COUNT(*) FROM order_reviews_clean_portfolio;
-- The downstream 09 script currently reads the EXISTING order_reviews_clean.
-- Only switch its input after checking row counts and scoring outputs match.
