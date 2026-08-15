-- ============================================================================
-- 11_TASK_PIPELINE.SQL — Task DAG for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA APP;

CREATE OR REPLACE TASK APP.TASK_RETRAIN_MODELS
  WAREHOUSE = SEMI_WH
  SCHEDULE = 'USING CRON 0 */6 * * * UTC'
  COMMENT = 'Retrain lead time forecast and disruption models'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_REFRESH_AI
  WAREHOUSE = SEMI_WH
  AFTER APP.TASK_RETRAIN_MODELS
  COMMENT = 'Refresh supplier risk classifications'
AS
  SELECT 1; -- Replace with actual refresh logic

CREATE OR REPLACE TASK APP.TASK_REFRESH_ICEBERG
  WAREHOUSE = SEMI_WH
  AFTER APP.TASK_REFRESH_AI
  COMMENT = 'Refresh Iceberg export for partner Athena access'
AS
  SELECT 1; -- Replace with actual refresh logic

ALTER TASK APP.TASK_REFRESH_ICEBERG RESUME;
ALTER TASK APP.TASK_REFRESH_AI RESUME;
ALTER TASK APP.TASK_RETRAIN_MODELS RESUME;
