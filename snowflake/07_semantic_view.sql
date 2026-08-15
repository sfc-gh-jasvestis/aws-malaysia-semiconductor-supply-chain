-- ============================================================================
-- 07_SEMANTIC_VIEW.SQL — Semantic View for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA APP;

CREATE OR REPLACE SEMANTIC VIEW APP.SUPPLY_CHAIN_ANALYTICS
  COMMENT = 'Semiconductor supply chain, procurement, and supplier risk analytics'
AS
  TABLES (
    CURATED.SUPPLIER_RISK_SCORE AS supplier_risk_score,CURATED.BOM_COST_ROLLUP AS bom_cost_rollup,CURATED.LEAD_TIME_ANALYTICS AS lead_time_analytics,CURATED.SUPPLY_GRAPH AS supply_graph
  );
