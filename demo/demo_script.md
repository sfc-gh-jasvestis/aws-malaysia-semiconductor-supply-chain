# Semiconductor Supplier Delivery Risk

**Malaysia - Semiconductor supply chain**
Use case: On-time delivery and delivery-miss risk for component suppliers feeding fictional assembly and test plants

> A fictional Malaysian semiconductor supply chain, 40 component suppliers from Bayan Lepas to Kuching, tracked from supplier dispatch to plant receiving: dynamic tables for on-time delivery, a holdout-evaluated delivery-miss classifier, an inbound shipment forecast and grounded AI answers. Exception checks are demo signals, not supplier audit or qualification verdicts.

## Why Snowflake

- **Dynamic tables** reconcile inbound shipments, on-time delivery, exception flags, confirmed delivery misses and supplier review completion from RAW supplier data, with checks in `run_core.py`
- **Delivery-miss classification** gives a holdout-evaluated next-7-day probability per supplier
- **Shipment forecast** projects 14 days of network-wide inbound shipments with prediction intervals, for receiving dock planning
- **Grounded AI**: the Cortex Agent (Analyst over a semantic view, plus Search over SOPs) shows its SQL and SOP citations
- **Live shipments**: a native shipment simulator (Snowflake only) or Amazon Data Firehose, S3 and Snowpipe (AWS build), then an alert and email

## What is built

| | |
|---|---|
| Dimension table | `RAW.SUPPLIERS` (40 rows) |
| Fact table | `RAW.SUPPLIER_DAILY` (3,600 supplier-days, 90 days) |
| Curated layer | `CURATED.KPI_SUMMARY`, `PERFORMANCE_SUMMARY`, `SIGNAL_SUMMARY`, `TREND_ANALYSIS` |
| ML | `ML.DELIVERY_RISK_SCORES`, `ML.DELIVERY_RISK_HOLDOUT_METRICS`, `ML.SHIPMENT_FORECAST`, `ML.ASN_VARIANCE_ANOMALIES` |

Cities: Bayan Lepas, Kulim, Ipoh, Shah Alam, Seremban, Melaka, Senai, Kuching.
Material categories: Bonding wire supplier, Lead frame supplier, Substrate supplier, Specialty chemicals supplier, Test consumables supplier.

## KPI cards (live from `CURATED.KPI_SUMMARY`; no fallback values)

| Card | Value from the seeded data |
|---|---|
| On-Time Delivery (units) | 86.4% |
| Inbound Shipments | 22,183 |
| Units Shipped (millions) | 829 |
| Delivery Exception Flags | 548 |
| Confirmed Delivery Misses | 110 |
| Flag Precision | 20.1% |
| Lots Quarantined at Receiving | 52 |
| Supplier Review Completion | 79.2% |
| Suppliers Monitored | 40 |
| Second-Source Coverage | 60.2% |
| Qualifications Pending | 503 |
| Active Part Numbers | 5,557 |

Values are synthetic. A rebuild reproduces them because the data is HASH-seeded; dates are relative to the build day.

## Demo flow

1. Executive Cockpit: KPIs, daily inbound shipments against exception flags, flags and confirmed delivery misses by exception signal, supplier table
2. Predictive: holdout metrics, risk bands, 14-day inbound shipment forecast, ASN quantity variance anomalies
3. Supplier Reviews: review completion, second-source coverage and pending qualifications, review completion against confirmed misses, then generate the action memo
4. Live Shipments: run `CALL APP.SIMULATE_SHIPMENTS(20)` (Snowflake only) or `python aws/publish_shipments.py --count 20` (AWS build). Then run `EXECUTE ALERT APP.LIVE_SHIPMENT_ALERT` and show the alert log and email.
5. Ask AI: the Cortex Agent answers metric questions through the semantic view and cites SOPs from Cortex Search. The SQL is shown.
6. QuickSight (AWS build): the same Snowflake tables through DIRECT_QUERY
7. Architecture: both builds side by side

## Talking points

- About one exception flag in five is confirmed as a delivery miss (20.1%). The rest are false positives, and that is where the supplier quality team loses its week.
- "Commit date slipped" produces the most confirmed misses (33) and the most flags (120). Customs clearance system outage flags hit every supplier in a city at once and are never confirmed.
- SUP-0018 (Ipoh substrate supplier) has the most confirmed misses (16), and substrate suppliers have the lowest on-time delivery (79.3%).
- The risk model is evaluated on a time-based holdout: precision 0.38 and recall 0.13 at 0.5, against a 0.21 base rate. Use it to order supplier calls, not as a verdict. Forecast and anomaly figures can shift slightly with the build day.
- Customs clearance outage days are excluded from model training, because the supplier did not cause them.

## Business impact

Use only the sourced references in `README.md` (Business Impact).
