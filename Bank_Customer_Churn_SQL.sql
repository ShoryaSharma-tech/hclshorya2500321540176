-- BANK CUSTOMER CHURN ANALYSIS - CONSOLIDATED ORACLE SQL
-- Run in Oracle SQL Developer after creating/choosing your schema.
-- Load bank_churn_dataset.csv into BANK_CUSTOMERS using SQL Developer's
-- Import Data wizard, matching the CSV columns to the table columns.
-- Then execute the analysis queries and create the views below.


-- ==================== 01_create_tables.sql ====================
-- Oracle SQL DDL: one row per customer for this single-snapshot churn project
CREATE TABLE BANK_CUSTOMERS (
    CUSTOMER_ID NUMBER(10) PRIMARY KEY,
    CREDIT_SCORE NUMBER(3),
    GEOGRAPHY VARCHAR2(30),
    GENDER VARCHAR2(10),
    AGE NUMBER(3),
    TENURE NUMBER(2),
    BALANCE NUMBER(14,2),
    NUM_OF_PRODUCTS NUMBER(2),
    HAS_CR_CARD NUMBER(1),
    IS_ACTIVE_MEMBER NUMBER(1),
    ESTIMATED_SALARY NUMBER(14,2),
    EXITED NUMBER(1) CHECK (EXITED IN (0,1))
);

-- Optional staging table can be used if you prefer loading the raw CSV first.
CREATE TABLE BANK_CUSTOMERS_STG (
    CUSTOMER_ID NUMBER(10), CREDIT_SCORE NUMBER(3), GEOGRAPHY VARCHAR2(30),
    GENDER VARCHAR2(10), AGE NUMBER(3), TENURE NUMBER(2), BALANCE NUMBER(14,2),
    NUM_OF_PRODUCTS NUMBER(2), HAS_CR_CARD NUMBER(1), IS_ACTIVE_MEMBER NUMBER(1),
    ESTIMATED_SALARY NUMBER(14,2), EXITED NUMBER(1)
);


-- ==================== 03_analysis_queries.sql ====================
-- Overall KPI summary
SELECT COUNT(*) AS total_customers,
       SUM(EXITED) AS churned_customers,
       COUNT(*) - SUM(EXITED) AS retained_customers,
       ROUND(100 * SUM(EXITED) / COUNT(*), 2) AS churn_rate_pct,
       ROUND(100 * (COUNT(*) - SUM(EXITED)) / COUNT(*), 2) AS retention_rate_pct
FROM BANK_CUSTOMERS;

-- Churn rate by geography
SELECT GEOGRAPHY, COUNT(*) AS customers, SUM(EXITED) AS churned,
       ROUND(100 * AVG(EXITED), 2) AS churn_rate_pct
FROM BANK_CUSTOMERS
GROUP BY GEOGRAPHY
ORDER BY churn_rate_pct DESC;

-- Churn rate by product count
SELECT NUM_OF_PRODUCTS, COUNT(*) AS customers, SUM(EXITED) AS churned,
       ROUND(100 * AVG(EXITED), 2) AS churn_rate_pct
FROM BANK_CUSTOMERS
GROUP BY NUM_OF_PRODUCTS
ORDER BY NUM_OF_PRODUCTS;

-- Churn rate by age band
SELECT CASE
         WHEN AGE <= 30 THEN '18-30'
         WHEN AGE <= 40 THEN '31-40'
         WHEN AGE <= 50 THEN '41-50'
         WHEN AGE <= 60 THEN '51-60'
         ELSE '61+'
       END AS AGE_GROUP,
       COUNT(*) AS customers, SUM(EXITED) AS churned,
       ROUND(100 * AVG(EXITED), 2) AS churn_rate_pct
FROM BANK_CUSTOMERS
GROUP BY CASE
           WHEN AGE <= 30 THEN '18-30'
           WHEN AGE <= 40 THEN '31-40'
           WHEN AGE <= 50 THEN '41-50'
           WHEN AGE <= 60 THEN '51-60'
           ELSE '61+'
         END
ORDER BY AGE_GROUP;

-- Validate zero-balance customers separately; zero balance is not automatically invalid.
SELECT CASE WHEN BALANCE = 0 THEN 'Zero balance' ELSE 'Positive balance' END AS BALANCE_GROUP,
       COUNT(*) AS customers, ROUND(100 * AVG(EXITED), 2) AS churn_rate_pct
FROM BANK_CUSTOMERS
GROUP BY CASE WHEN BALANCE = 0 THEN 'Zero balance' ELSE 'Positive balance' END;


-- ==================== 04_create_views.sql ====================
CREATE OR REPLACE VIEW VW_CHURN_KPIS AS
SELECT COUNT(*) AS TOTAL_CUSTOMERS,
       SUM(EXITED) AS CHURNED_CUSTOMERS,
       COUNT(*) - SUM(EXITED) AS RETAINED_CUSTOMERS,
       ROUND(100 * AVG(EXITED), 2) AS CHURN_RATE_PCT
FROM BANK_CUSTOMERS;

CREATE OR REPLACE VIEW VW_CHURN_BY_GEOGRAPHY AS
SELECT GEOGRAPHY, COUNT(*) AS CUSTOMERS,
       SUM(EXITED) AS CHURNED,
       ROUND(100 * AVG(EXITED), 2) AS CHURN_RATE_PCT
FROM BANK_CUSTOMERS
GROUP BY GEOGRAPHY;

CREATE OR REPLACE VIEW VW_CHURN_BY_PRODUCTS AS
SELECT NUM_OF_PRODUCTS, COUNT(*) AS CUSTOMERS,
       SUM(EXITED) AS CHURNED,
       ROUND(100 * AVG(EXITED), 2) AS CHURN_RATE_PCT
FROM BANK_CUSTOMERS
GROUP BY NUM_OF_PRODUCTS;
