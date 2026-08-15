-- ============================================================================
-- 03_STAGING.SQL — Generate synthetic data for Semiconductor Supply Chain Visibility
-- Country: MALAYSIA | Currency: MYR
-- ============================================================================
USE DATABASE SEMICONDUCTOR_SUPPLY_CHAIN;
USE SCHEMA RAW;

-- Data generation scripts are demo-specific.
-- See the handcrafted SQL in the aws-malaysia-semiconductor-yield demo for
-- the full pattern: GENERATOR + UNIFORM + LATERAL for distribution,
-- Cortex Complete for text generation, engineered key demo numbers.

-- Target row counts:
-- SUPPLIERS: 50 rows — Tier-1 and tier-2 suppliers across ASEAN and East Asia
-- BOM_ITEMS: 2,000 rows — Multi-level bill of materials with parent-child relationships
-- PURCHASE_ORDERS: 10,000 rows — 12 months of procurement orders with delivery tracking
-- SHIPMENTS: 5,000 rows — Inbound shipment tracking with carrier and customs data
-- SUPPLIER_DOCS: 60 rows — Contracts, quality audits, compliance certificates, risk assessments
-- ASEAN_TRADE: 12 rows — Regional trade flow and tariff context
