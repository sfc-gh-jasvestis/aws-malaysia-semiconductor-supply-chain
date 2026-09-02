-- Generated from generator/demo_specs/aws-malaysia-semiconductor-supply-chain.json
-- Regenerate with: python3 generator/gen_repo_docs.py aws-malaysia-semiconductor-supply-chain
-- This is the schema that is actually deployed for MY_SEMICONDUCTOR_SUPPLY_CHAIN.

-- MY_SEMICONDUCTOR_SUPPLY_CHAIN  (Semiconductor Supply Chain Visibility)
-- generated from generator/demo_specs/aws-malaysia-semiconductor-supply-chain.json - do not hand-edit
CREATE DATABASE IF NOT EXISTS MY_SEMICONDUCTOR_SUPPLY_CHAIN;
CREATE SCHEMA IF NOT EXISTS MY_SEMICONDUCTOR_SUPPLY_CHAIN.RAW;
CREATE SCHEMA IF NOT EXISTS MY_SEMICONDUCTOR_SUPPLY_CHAIN.CURATED;
CREATE SCHEMA IF NOT EXISTS MY_SEMICONDUCTOR_SUPPLY_CHAIN.APP;
USE DATABASE MY_SEMICONDUCTOR_SUPPLY_CHAIN;

-- 5 real regions; entity names carry their region so the two always agree
