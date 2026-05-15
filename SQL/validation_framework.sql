-- ============================================================
-- SQL DATA VALIDATION FRAMEWORK
-- Author: Albert Lade
-- Description: Metadata-driven post-load validation checks
--              covering Completeness, Uniqueness, Validity,
--              Consistency, and Timeliness.
-- Compatible:  PostgreSQL / SQL Server
-- ============================================================


-- ============================================================
-- SECTION 1: SCHEMA SETUP
-- ============================================================

-- Stores all validation rules — no logic is hardcoded in
-- check scripts. Add a new check by inserting a row here.
CREATE TABLE IF NOT EXISTS validation_rules (
    rule_id         SERIAL PRIMARY KEY,
    check_name      VARCHAR(100)  NOT NULL,
    category        VARCHAR(50)   NOT NULL,  -- Completeness | Uniqueness | Validity | Consistency | Timeliness
    target_table    VARCHAR(100)  NOT NULL,
    check_sql       TEXT          NOT NULL,
    severity        VARCHAR(20)   NOT NULL DEFAULT 'warning', -- 'critical' | 'warning'
    is_active       BOOLEAN       NOT NULL DEFAULT TRUE
);

-- Persists every check result for trending and audit
CREATE TABLE IF NOT EXISTS validation_results (
    result_id       SERIAL PRIMARY KEY,
    run_timestamp   TIMESTAMP     NOT NULL DEFAULT NOW(),
    check_name      VARCHAR(100)  NOT NULL,
    category        VARCHAR(50)   NOT NULL,
    target_table    VARCHAR(100)  NOT NULL,
    failed_rows     INT           NOT NULL,
    status          VARCHAR(20)   NOT NULL,  -- 'PASSED' | 'FAILED' | 'WARNING'
    severity        VARCHAR(20)   NOT NULL
);


-- ============================================================
-- SECTION 2: REGISTER VALIDATION RULES
-- ============================================================

INSERT INTO validation_rules (check_name, category, target_table, check_sql, severity) VALUES

-- COMPLETENESS — null / missing required fields
('customer_id_null_check',    'Completeness', 'orders',      'SELECT COUNT(*) FROM orders WHERE customer_id IS NULL',             'critical'),
('order_date_null_check',     'Completeness', 'orders',      'SELECT COUNT(*) FROM orders WHERE order_date IS NULL',              'critical'),
('product_id_null_check',     'Completeness', 'order_items', 'SELECT COUNT(*) FROM order_items WHERE product_id IS NULL',         'critical'),
('unit_price_null_check',     'Completeness', 'order_items', 'SELECT COUNT(*) FROM order_items WHERE unit_price IS NULL',         'warning'),

-- UNIQUENESS — duplicate primary / business keys
('order_id_duplicate_check',  'Uniqueness',   'orders',      'SELECT COUNT(*) - COUNT(DISTINCT order_id) FROM orders',           'critical'),
('customer_id_dup_check',     'Uniqueness',   'customers',   'SELECT COUNT(*) - COUNT(DISTINCT customer_id) FROM customers',     'critical'),
('product_id_dup_check',      'Uniqueness',   'products',    'SELECT COUNT(*) - COUNT(DISTINCT product_id) FROM products',       'warning'),

-- VALIDITY — values within expected range or format
('negative_price_check',      'Validity',     'order_items', 'SELECT COUNT(*) FROM order_items WHERE unit_price < 0',             'critical'),
('zero_quantity_check',       'Validity',     'order_items', 'SELECT COUNT(*) FROM order_items WHERE quantity <= 0',              'warning'),
('future_order_date_check',   'Validity',     'orders',      'SELECT COUNT(*) FROM orders WHERE order_date > NOW()',              'warning'),
('invalid_status_check',      'Validity',     'orders',      'SELECT COUNT(*) FROM orders WHERE status NOT IN (''pending'', ''shipped'', ''delivered'', ''cancelled'')', 'warning'),

-- CONSISTENCY — referential integrity and business logic
('orphaned_order_lines',      'Consistency',  'order_items', 'SELECT COUNT(*) FROM order_items oi LEFT JOIN orders o ON oi.order_id = o.order_id WHERE o.order_id IS NULL',    'critical'),
('orphaned_orders',           'Consistency',  'orders',      'SELECT COUNT(*) FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL', 'critical'),
('ship_before_order_check',   'Consistency',  'orders',      'SELECT COUNT(*) FROM orders WHERE ship_date < order_date',         'critical'),
('invalid_product_ref',       'Consistency',  'order_items', 'SELECT COUNT(*) FROM order_items oi LEFT JOIN products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL', 'warning'),

-- TIMELINESS — data freshness and load lag
('orders_load_lag_check',     'Timeliness',   'orders',      'SELECT CASE WHEN MAX(order_date) < NOW() - INTERVAL ''1 day'' THEN 1 ELSE 0 END FROM orders',     'critical'),
('customers_load_lag_check',  'Timeliness',   'customers',   'SELECT CASE WHEN MAX(created_date) < NOW() - INTERVAL ''2 days'' THEN 1 ELSE 0 END FROM customers', 'warning');


-- ============================================================
-- SECTION 3: INDIVIDUAL VALIDATION CHECKS
-- ============================================================
-- These are the standalone executable versions of each check.
-- The orchestrator (orchestrator.py) runs these dynamically
-- by reading check_sql from validation_rules. The queries
-- below are provided here for manual testing and reference.

-- --- COMPLETENESS -------------------------------------------

-- Null check: customer_id
SELECT 'customer_id_null_check'      AS check_name,
       'Completeness'                AS category,
       COUNT(*)                      AS failed_rows
FROM   orders
WHERE  customer_id IS NULL;

-- Null check: order_date
SELECT 'order_date_null_check'       AS check_name,
       'Completeness'                AS category,
       COUNT(*)                      AS failed_rows
FROM   orders
WHERE  order_date IS NULL;

-- Null check: product_id in order line items
SELECT 'product_id_null_check'       AS check_name,
       'Completeness'                AS category,
       COUNT(*)                      AS failed_rows
FROM   order_items
WHERE  product_id IS NULL;


-- --- UNIQUENESS ---------------------------------------------

-- Duplicate order_id detection
SELECT 'order_id_duplicate_check'    AS check_name,
       'Uniqueness'                  AS category,
       COUNT(*) - COUNT(DISTINCT order_id) AS failed_rows
FROM   orders;

-- Duplicate customer_id detection
SELECT 'customer_id_dup_check'       AS check_name,
       'Uniqueness'                  AS category,
       COUNT(*) - COUNT(DISTINCT customer_id) AS failed_rows
FROM   customers;


-- --- VALIDITY -----------------------------------------------

-- Negative unit prices
SELECT 'negative_price_check'        AS check_name,
       'Validity'                    AS category,
       COUNT(*)                      AS failed_rows
FROM   order_items
WHERE  unit_price < 0;

-- Zero or negative quantity
SELECT 'zero_quantity_check'         AS check_name,
       'Validity'                    AS category,
       COUNT(*)                      AS failed_rows
FROM   order_items
WHERE  quantity <= 0;

-- Future-dated orders
SELECT 'future_order_date_check'     AS check_name,
       'Validity'                    AS category,
       COUNT(*)                      AS failed_rows
FROM   orders
WHERE  order_date > NOW();

-- Invalid order status values
SELECT 'invalid_status_check'        AS check_name,
       'Validity'                    AS category,
       COUNT(*)                      AS failed_rows
FROM   orders
WHERE  status NOT IN ('pending', 'shipped', 'delivered', 'cancelled');


-- --- CONSISTENCY --------------------------------------------

-- Orphaned order line items (no matching parent order)
SELECT 'orphaned_order_lines'        AS check_name,
       'Consistency'                 AS category,
       COUNT(*)                      AS failed_rows
FROM   order_items oi
LEFT JOIN orders o ON oi.order_id = o.order_id
WHERE  o.order_id IS NULL;

-- Orphaned orders (no matching customer)
SELECT 'orphaned_orders'             AS check_name,
       'Consistency'                 AS category,
       COUNT(*)                      AS failed_rows
FROM   orders o
LEFT JOIN customers c ON o.customer_id = c.customer_id
WHERE  c.customer_id IS NULL;

-- Ship date before order date (logic violation)
SELECT 'ship_before_order_check'     AS check_name,
       'Consistency'                 AS category,
       COUNT(*)                      AS failed_rows
FROM   orders
WHERE  ship_date < order_date;

-- Order items referencing non-existent products
SELECT 'invalid_product_ref'         AS check_name,
       'Consistency'                 AS category,
       COUNT(*)                      AS failed_rows
FROM   order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE  p.product_id IS NULL;


-- --- TIMELINESS ---------------------------------------------

-- Orders table load lag: most recent record older than 1 day
SELECT 'orders_load_lag_check'       AS check_name,
       'Timeliness'                  AS category,
       CASE
           WHEN MAX(order_date) < NOW() - INTERVAL '1 day' THEN 1
           ELSE 0
       END                           AS failed_rows
FROM   orders;

-- Customers table load lag: most recent record older than 2 days
SELECT 'customers_load_lag_check'    AS check_name,
       'Timeliness'                  AS category,
       CASE
           WHEN MAX(created_date) < NOW() - INTERVAL '2 days' THEN 1
           ELSE 0
       END                           AS failed_rows
FROM   customers;


-- ============================================================
-- SECTION 4: LOG RESULTS TO validation_results
-- ============================================================
-- Template used by orchestrator.py to write each check result.
-- Replace :check_name, :category, :target_table, :failed_rows,
-- :status, and :severity with values from the run.

INSERT INTO validation_results (
    run_timestamp,
    check_name,
    category,
    target_table,
    failed_rows,
    status,
    severity
)
VALUES (
    NOW(),
    :check_name,
    :category,
    :target_table,
    :failed_rows,
    CASE
        WHEN :failed_rows = 0 THEN 'PASSED'
        WHEN :severity = 'warning' THEN 'WARNING'
        ELSE 'FAILED'
    END,
    :severity
);


-- ============================================================
-- SECTION 5: DATA QUALITY MONITORING VIEW
-- ============================================================
-- Powers the live data quality dashboard.
-- Shows daily pass/fail rate by category, rolling 30 days.

CREATE OR REPLACE VIEW data_quality_summary AS
SELECT
    DATE(run_timestamp)                                                 AS check_date,
    category,
    COUNT(*)                                                            AS total_checks,
    SUM(CASE WHEN status = 'PASSED'  THEN 1 ELSE 0 END)                AS passed,
    SUM(CASE WHEN status = 'FAILED'  THEN 1 ELSE 0 END)                AS failed,
    SUM(CASE WHEN status = 'WARNING' THEN 1 ELSE 0 END)                AS warnings,
    ROUND(
        100.0 * SUM(CASE WHEN status = 'PASSED' THEN 1 ELSE 0 END)
        / COUNT(*), 1
    )                                                                   AS pass_rate_pct
FROM   validation_results
WHERE  run_timestamp >= NOW() - INTERVAL '30 days'
GROUP  BY DATE(run_timestamp), category
ORDER  BY check_date DESC, category;


-- ============================================================
-- SECTION 6: USEFUL OPERATIONAL QUERIES
-- ============================================================

-- Most frequently failing checks (all time)
SELECT   check_name,
         category,
         target_table,
         COUNT(*)        AS total_runs,
         SUM(CASE WHEN status IN ('FAILED', 'WARNING') THEN 1 ELSE 0 END) AS total_failures,
         ROUND(
             100.0 * SUM(CASE WHEN status IN ('FAILED', 'WARNING') THEN 1 ELSE 0 END)
             / COUNT(*), 1
         )               AS failure_rate_pct
FROM     validation_results
GROUP BY check_name, category, target_table
ORDER BY total_failures DESC;

-- All critical failures from the most recent run
SELECT   check_name,
         category,
         target_table,
         failed_rows,
         run_timestamp
FROM     validation_results
WHERE    severity  = 'critical'
AND      status    = 'FAILED'
AND      DATE(run_timestamp) = (SELECT MAX(DATE(run_timestamp)) FROM validation_results)
ORDER BY failed_rows DESC;

-- Pipeline health summary — latest run per table
SELECT   target_table,
         COUNT(*)        AS checks_run,
         SUM(CASE WHEN status = 'PASSED'  THEN 1 ELSE 0 END) AS passed,
         SUM(CASE WHEN status = 'FAILED'  THEN 1 ELSE 0 END) AS failed,
         MAX(run_timestamp)                                   AS last_run
FROM     validation_results
WHERE    DATE(run_timestamp) = (SELECT MAX(DATE(run_timestamp)) FROM validation_results)
GROUP BY target_table
ORDER BY failed DESC, target_table;
