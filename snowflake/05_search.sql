-- ============================================================================
-- 05_SEARCH.SQL — Cortex Search for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA SEARCH;

CREATE OR REPLACE CORTEX SEARCH SERVICE SEARCH.SUPPLIER_DOCS_SEARCH
  ON CONTENT
  ATTRIBUTES DOC_TYPE, SUPPLIER_ID, RISK_CATEGORY
  WAREHOUSE = SEMI_WH
  TARGET_LAG = '1 hour'
AS (
  SELECT * FROM RAW.SUPPLIER_DOCS
);
