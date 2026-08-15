-- ============================================================================
-- Semiconductor Supply Chain Visibility
-- Multi-tier BOM tracking across 50 suppliers for Malaysia's semiconductor corridor — Snowflake Dynamic Tables build real-time supply graphs while Iceberg enables partner access via Athena.
-- ============================================================================
USE ROLE ACCOUNTADMIN;
CREATE DATABASE IF NOT EXISTS SEMICONDUCTOR_SUPPLY_CHAIN;
CREATE WAREHOUSE IF NOT EXISTS SEMI_WH WAREHOUSE_SIZE = 'MEDIUM' AUTO_SUSPEND = 120 AUTO_RESUME = TRUE;
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
CREATE SCHEMA IF NOT EXISTS RAW;
CREATE SCHEMA IF NOT EXISTS CURATED;
CREATE SCHEMA IF NOT EXISTS ML;
CREATE SCHEMA IF NOT EXISTS AI;
CREATE SCHEMA IF NOT EXISTS SEARCH;
CREATE SCHEMA IF NOT EXISTS APP;

USE WAREHOUSE SEMI_WH;
