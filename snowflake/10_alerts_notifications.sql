-- ============================================================================
-- 10_ALERTS_NOTIFICATIONS.SQL — Alerts for Semiconductor Supply Chain Visibility
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA APP;

-- Notification integration (email)
CREATE OR REPLACE NOTIFICATION INTEGRATION aws_malaysia_semiconductor_supply_chain_EMAIL_INT
  TYPE = EMAIL
  ENABLED = TRUE
  ALLOWED_RECIPIENTS = ('<YOUR_EMAIL>');

-- Alert: SUPPLIER_HIGH_RISK_ALERT
CREATE OR REPLACE ALERT APP.SUPPLIER_HIGH_RISK_ALERT
  WAREHOUSE = SEMI_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Supplier risk score exceeds critical threshold'
IF (EXISTS (
  SELECT 1 FROM CURATED.SUPPLIER_RISK_SCORE
  WHERE 1=1 -- Condition: RISK_SCORE > 80 for any supplier
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_malaysia_semiconductor_supply_chain_EMAIL_INT',
    '<YOUR_EMAIL>',
    '[ALERT] Semiconductor Supply Chain Visibility: Supplier risk score exceeds critical threshold',
    'Supplier risk score exceeds critical threshold'
  );

ALTER ALERT APP.SUPPLIER_HIGH_RISK_ALERT RESUME;

-- Alert: LEAD_TIME_DEVIATION_ALERT
CREATE OR REPLACE ALERT APP.LEAD_TIME_DEVIATION_ALERT
  WAREHOUSE = SEMI_WH
  SCHEDULE = '5 MINUTE'
  COMMENT = 'Purchase order lead time deviation exceeds 14 days'
IF (EXISTS (
  SELECT 1 FROM CURATED.SUPPLIER_RISK_SCORE
  WHERE 1=1 -- Condition: LEAD_TIME_DEVIATION_DAYS > 14 for any PO
))
THEN
  CALL SYSTEM$SEND_EMAIL(
    'aws_malaysia_semiconductor_supply_chain_EMAIL_INT',
    '<YOUR_EMAIL>',
    '[ALERT] Semiconductor Supply Chain Visibility: Purchase order lead time deviation exceeds 14 days',
    'Purchase order lead time deviation exceeds 14 days'
  );

ALTER ALERT APP.LEAD_TIME_DEVIATION_ALERT RESUME;

