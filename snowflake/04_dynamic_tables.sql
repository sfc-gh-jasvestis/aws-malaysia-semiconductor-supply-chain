-- ============================================================================
-- 04_DYNAMIC_TABLES.SQL — Curated layer for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA CURATED;

-- SUPPLIER_RISK_SCORE: Real-time supplier risk scoring based on delivery performance, financial health, and concentration
-- Source: SUPPLIERS, PURCHASE_ORDERS, SHIPMENTS
CREATE OR REPLACE DYNAMIC TABLE CURATED.SUPPLIER_RISK_SCORE
  TARGET_LAG = '5 minutes'
  WAREHOUSE = SEMI_WH
AS
SELECT * FROM RAW.SUPPLIERS;
-- TODO: Replace with actual join/aggregation logic per demo

-- BOM_COST_ROLLUP: Multi-level BOM cost aggregation with variance tracking
-- Source: BOM_ITEMS, PURCHASE_ORDERS
CREATE OR REPLACE DYNAMIC TABLE CURATED.BOM_COST_ROLLUP
  TARGET_LAG = '5 minutes'
  WAREHOUSE = SEMI_WH
AS
SELECT * FROM RAW.BOM_ITEMS;
-- TODO: Replace with actual join/aggregation logic per demo

-- LEAD_TIME_ANALYTICS: Supplier lead time deviation and trend analysis
-- Source: PURCHASE_ORDERS, SHIPMENTS
CREATE OR REPLACE DYNAMIC TABLE CURATED.LEAD_TIME_ANALYTICS
  TARGET_LAG = '5 minutes'
  WAREHOUSE = SEMI_WH
AS
SELECT * FROM RAW.PURCHASE_ORDERS;
-- TODO: Replace with actual join/aggregation logic per demo

-- SUPPLY_GRAPH: Multi-tier supplier dependency graph for concentration risk
-- Source: SUPPLIERS, BOM_ITEMS
CREATE OR REPLACE DYNAMIC TABLE CURATED.SUPPLY_GRAPH
  TARGET_LAG = '5 minutes'
  WAREHOUSE = SEMI_WH
AS
SELECT * FROM RAW.SUPPLIERS;
-- TODO: Replace with actual join/aggregation logic per demo

