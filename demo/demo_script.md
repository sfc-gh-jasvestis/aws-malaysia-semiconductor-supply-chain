# Semiconductor Supply Chain Visibility

**Malaysia - Semiconductor & Electronics Manufacturing**
Use case: Supply Chain Visibility

> Multi-tier BOM tracking across 50 suppliers for Malaysia's semiconductor corridor — Snowflake Dynamic Tables build real-time supply graphs while Iceberg enables partner access via Athena.

## Why Snowflake

Snowflake builds the supply chain graph natively — every BOM level, supplier risk, and lead time tracked in Dynamic Tables, exported as Iceberg for partner self-service

- **Multi-tier BOM graph in Dynamic Tables** - Only demo building recursive supply chain graphs natively in Snowflake SQL
- **Iceberg export for partner Athena access** - Demonstrates open data sharing without copying — partners self-serve via their own tools
- **ML.FORECAST for lead time prediction** - Predicts supplier delivery delays before they impact production scheduling
- **ML.ANOMALY_DETECTION for supply disruption** - Detects unusual supplier delivery patterns as early warning of disruption
- **60 supplier documents searchable via Cortex Search** - Contracts, audits, and compliance certs instantly queryable for risk assessment
- **Malaysian semiconductor supply chain context** - RM 890M procurement with realistic ASEAN supplier names and trade routes

## What is deployed

| | |
|---|---|
| Database | `MY_SEMICONDUCTOR_SUPPLY_CHAIN` |
| Service | `MY_SEMICONDUCTOR_SUPPLY_CHAIN_APP` |
| Compute pool | `SEA_DEMOS_MALAYSIA_POOL` |
| Dimension table | `RAW.ASEAN_TRADE` (20 rows) |
| Fact table | `RAW.PURCHASE_ORDERS` (250,000 rows, 90 days) |
| Curated layer | `CURATED.PERFORMANCE_SUMMARY`, `CURATED.TREND_ANALYSIS`, `CURATED.KPI_SUMMARY` |
| Currency | MYR (RM) |

Regions in play: Selangor, Johor, Penang, Sabah, Sarawak
Segments: Substrate, Leadframe, Bonding Wire, Mold Compound

Dynamic tables are created suspended and refreshed on demand:

```bash
./refresh_demo_data.sh MY_SEMICONDUCTOR_SUPPLY_CHAIN
```

## KPI cards

Every card below is served live from `CURATED.KPI_SUMMARY`. The app keeps the
original literal as a fallback, so it still renders if Snowflake is unreachable.

| Card | Value | Backed by |
|---|---|---|
| On-Time Delivery | `94%` | average per event |
| Component Shortage | `8 SKUs` | average per event |
| Lead Time (Avg) | `6.2 weeks` | average per event |
| Active Suppliers | `124` | total across Asean Trade |
| Single-Source Risk | `RM 42M` | total across Asean Trade |
| Buffer Stock | `8 days` | average per event |
| Alternatives | `84%` | average per event |


## Demo flow

1. Supply Chain Overview
2. BOM Analytics
3. Predictive Intelligence
4. Ask AI
5. Architecture & Data

## Talking points

- **50 tier-1 suppliers** - tracked across ASEAN and East Asia
- **3 suppliers** - flagged HIGH RISK (delivery + financial + concentration)
- **RM 890M** - annual procurement spend (US$205M)
- **12-day average** - lead time deviation across all suppliers
- **60 supplier docs** - indexed and searchable via Cortex Search
- **7 components** - single-source dependency (no qualified alternative)

## Business impact

- Malaysia semiconductor exports reached RM 450B (US$98B) in 2023, representing 18.4% of GDP (MIDA)
- Supply chain disruptions cost semiconductor companies 3-5% of annual revenue on average (McKinsey Supply Chain)
- Companies with advanced supply chain visibility reduce lead time variability by 50% (Gartner Supply Chain)
- Honeywell achieved real-time supply chain intelligence on Snowflake (Snowflake Customers)

---
Generated from `generator/demo_specs/aws-malaysia-semiconductor-supply-chain.json`. Do not hand-edit: run
`python3 generator/gen_repo_docs.py aws-malaysia-semiconductor-supply-chain` instead.
