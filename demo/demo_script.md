# Demo Script: Semiconductor Supply Chain Visibility
## ~4-Minute Recorded Walkthrough
**Format**: Screen recording with voiceover
**Target**: Customer meeting / booth loop / social share
**Narrative**: "Snowflake builds the supply chain graph natively — every BOM level, supplier risk, and lead time tracked in Dynamic Tables, exported as Iceberg for partner self-service"
**Demo Mode**: Open app with `?demo=true` for presenter notes

---

## Two Personas

| Persona | Role | Tool | What they care about |
|---|---|---|---|
| **Lim Chee Keong** | Chief Supply Chain Officer | React App (SPCS) | Supply continuity, supplier risk concentration, lead time variance, BOM cost escalation |
| **Siti Nurhaliza binti Ahmad** | Procurement Manager | Amazon QuickSight | Purchase order lead times, supplier delivery performance, BOM cost variance, alternative sourcing |

---

## What's Built

| Layer | Component | Detail |
|---|---|---|
| **RAW** | 6 tables | SUPPLIERS (50), BOM_ITEMS (2000), PURCHASE_ORDERS (10000), SHIPMENTS (5000), SUPPLIER_DOCS (60), ASEAN_TRADE (12) |
| **CURATED** | 4 Dynamic Tables | SUPPLIER_RISK_SCORE, BOM_COST_ROLLUP, LEAD_TIME_ANALYTICS, SUPPLY_GRAPH |
| **ML** | ML.FORECAST + ML.ANOMALY_DETECTION | Forecasting + anomaly detection |
| **AI** | COMPLETE, AI_CLASSIFY, SUMMARIZE | Classification + extraction |
| **Search** | Cortex Search | 60 documents indexed |
| **Agent** | SUPPLY_CHAIN_INTELLIGENCE_AGENT | Semantic View + Search tools |


---

## The Story

Malaysia's semiconductor corridor relies on 50+ tier-1 suppliers spanning ASEAN and East Asia. A single supplier disruption can cascade through multi-level BOMs, halting production lines within days. With RM 890M in annual procurement and 12-day average lead time deviations, the CSCO needs real-time visibility into supplier risk, not monthly spreadsheet reviews.

---

## Script

### [0:00–0:45] SUPPLY CHAIN OVERVIEW

**Show**: Supply Chain Overview tab

> "RM 890 million in annual procurement across 50 tier-1 suppliers in the Penang-Kulim semiconductor corridor."

**Action**: Point at RM 890M procurement KPI

### [0:45–1:30] BOM ANALYTICS

**Show**: BOM Analytics tab

> "2,000 BOM items tracked across 5 product families — multi-level parent-child relationships."

**Action**: Show BOM tree visualization

### [1:30–2:15] PREDICTIVE INTELLIGENCE

**Show**: Predictive Intelligence tab

> "ML.FORECAST predicts lead time for each supplier 30 days forward — two suppliers trending toward SLA breach."

**Action**: Show lead time forecast chart with confidence bands

### [2:15–3:00] ASK AI

**Show**: Ask AI tab

> "Lim Chee Keong asks: 'Which suppliers have the highest risk of disruption next quarter?'"

**Action**: Type: 'Which suppliers are at highest risk next quarter?'

### [3:00–3:45] ARCHITECTURE & DATA

**Show**: Architecture & Data tab

> "Six Snowflake capabilities, six AWS services — Iceberg as the interoperability layer."

**Action**: Walk through architecture diagram


---

## Key Demo Differentiators

1. **Multi-tier BOM graph in Dynamic Tables** — Only demo building recursive supply chain graphs natively in Snowflake SQL
2. **Iceberg export for partner Athena access** — Demonstrates open data sharing without copying — partners self-serve via their own tools
3. **ML.FORECAST for lead time prediction** — Predicts supplier delivery delays before they impact production scheduling
4. **ML.ANOMALY_DETECTION for supply disruption** — Detects unusual supplier delivery patterns as early warning of disruption
5. **60 supplier documents searchable via Cortex Search** — Contracts, audits, and compliance certs instantly queryable for risk assessment
6. **Malaysian semiconductor supply chain context** — RM 890M procurement with realistic ASEAN supplier names and trade routes


---

## Demo Prep Checklist

### Data Verification
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.RAW.SUPPLIERS` → 50
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.RAW.BOM_ITEMS` → 2000
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.RAW.PURCHASE_ORDERS` → 10000
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.CURATED.SUPPLIER_RISK_SCORE WHERE RISK_LEVEL = 'HIGH'` → 3

### ML Model Verification
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.ML.LEAD_TIME_FORECAST_RESULTS` → >0

### AI/Agent Verification
- [ ] `SELECT COUNT(*) FROM SEMICONDUCTOR_SUPPLY_CHAIN.AI.DOC_CLASSIFICATION` → 60

