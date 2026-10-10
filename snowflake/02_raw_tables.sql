-- Synthetic supplier observations for a fictional semiconductor assembly and
-- test (OSAT) supply chain in Malaysia. 40 suppliers = 8 cities x 5 material
-- categories. Nothing is seeded as a prediction. Randomness is HASH-seeded, so
-- every rebuild is reproducible: per-supplier delivery-miss propensity, drift
-- between periodic supplier performance reviews, skipped reviews,
-- category-weighted exception signals, false-positive exception flags, and two
-- area-wide customs clearance system outages. Exception checks are demo
-- signals, not supplier audit or qualification verdicts.
USE DATABASE IDENTIFIER($DEMO_DB);
USE SCHEMA RAW;
USE WAREHOUSE IDENTIFIER($DEMO_WH);

CREATE TABLE RAW.SUPPLIERS AS
WITH suppliers AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS SUPPLIER_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 40))
), draws AS (
  SELECT SUPPLIER_INDEX,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-program')), 1000000) / 1e6 AS U_PROGRAM,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-rate')), 1000000) / 1e6 AS U_RATE,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-review')), 1000000) / 1e6 AS U_REVIEW,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-discipline')), 1000000) / 1e6 AS U_DISCIPLINE,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-tier')), 1000000) / 1e6 AS U_TIER,
         MOD(ABS(HASH(SUPPLIER_INDEX, 'mysc-size')), 1000000) / 1e6 AS U_SIZE
  FROM suppliers
), suppliers_named AS (
  SELECT *,
         -- Every city x material category combination appears exactly once.
         CASE MOD(SUPPLIER_INDEX, 8) WHEN 0 THEN 'Bayan Lepas' WHEN 1 THEN 'Kulim'
              WHEN 2 THEN 'Ipoh' WHEN 3 THEN 'Shah Alam' WHEN 4 THEN 'Seremban'
              WHEN 5 THEN 'Melaka' WHEN 6 THEN 'Senai'
              ELSE 'Kuching' END AS REGION,
         CASE FLOOR(SUPPLIER_INDEX / 8) WHEN 0 THEN 'Bonding wire supplier'
              WHEN 1 THEN 'Lead frame supplier' WHEN 2 THEN 'Substrate supplier'
              WHEN 3 THEN 'Specialty chemicals supplier' ELSE 'Test consumables supplier' END AS CATEGORY
  FROM draws
)
SELECT 'SUP-' || LPAD(SUPPLIER_INDEX::VARCHAR, 4, '0') AS ID,
       REGION || ' ' || CATEGORY AS NAME,
       REGION, CATEGORY, SUPPLIER_INDEX,
       1 + FLOOR(U_TIER * 3) AS RISK_TIER,
       ROUND(0.5 + U_PROGRAM * 7.5, 1) AS PROGRAM_YEARS,
       ROUND(0.6 + U_SIZE * 0.8, 3) AS SIZE_FACTOR,
       -- Base daily probability of a confirmed delivery miss, higher for
       -- capacity-constrained categories; ~15% of suppliers are weak links (x3).
       (0.004 + U_RATE * 0.020)
         * CASE CATEGORY WHEN 'Bonding wire supplier' THEN 0.4 WHEN 'Lead frame supplier' THEN 0.8
                         WHEN 'Substrate supplier' THEN 1.5 WHEN 'Specialty chemicals supplier' THEN 1.3
                         ELSE 1.1 END
         * IFF(U_RATE > 0.85, 3, 1) AS BASE_MISS_RATE,
       7 * (1 + FLOOR(U_REVIEW * 3)) AS REVIEW_INTERVAL_DAYS,
       0.55 + U_DISCIPLINE * 0.45 AS REVIEW_RETURN_PROB,
       -- Share of shipped units that typically arrive after the PO commit date.
       CASE CATEGORY WHEN 'Bonding wire supplier' THEN 3 WHEN 'Lead frame supplier' THEN 6
                     WHEN 'Substrate supplier' THEN 15 WHEN 'Specialty chemicals supplier' THEN 11
                     ELSE 9 END AS BASE_LATE_PCT,
       'Active' AS STATUS
FROM suppliers_named;

CREATE TABLE RAW.SUPPLIER_DAILY AS
WITH days AS (
  SELECT ROW_NUMBER() OVER (ORDER BY SEQ4()) - 1 AS DAY_INDEX
  FROM TABLE(GENERATOR(ROWCOUNT => 90))
), outage_events AS (
  -- Two area-wide customs clearance system outages; every supplier in the city gets a flag.
  SELECT * FROM VALUES (29, 'Kulim'), (66, 'Senai') AS o(DAY_INDEX, REGION)
), base AS (
  SELECT s.ID AS ENTITY_ID, s.SUPPLIER_INDEX, s.CATEGORY, s.REGION, s.PROGRAM_YEARS,
         s.SIZE_FACTOR, s.BASE_LATE_PCT,
         s.BASE_MISS_RATE, s.REVIEW_INTERVAL_DAYS, s.REVIEW_RETURN_PROB,
         d.DAY_INDEX,
         DATEADD('day', d.DAY_INDEX - 89, CURRENT_DATE()) AS EVENT_DATE,
         MOD(d.DAY_INDEX + s.SUPPLIER_INDEX * 3, s.REVIEW_INTERVAL_DAYS) AS DAYS_SINCE_REVIEW,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-miss')), 1000000) / 1e6 AS U_MISS,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-detect')), 1000000) / 1e6 AS U_DETECT,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-fp')), 1000000) / 1e6 AS U_FP,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-signal')), 1000000) / 1e6 AS U_SIG,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-done')), 1000000) / 1e6 AS U_DONE,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-ship')), 1000000) / 1e6 AS U_SHIP,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-noise')), 1000000) / 1e6 AS U_NOISE,
         MOD(ABS(HASH(s.ID, d.DAY_INDEX, 'mysc-hold')), 1000000) / 1e6 AS U_HOLD,
         o.REGION IS NOT NULL AS OUTAGE_EVENT
  FROM RAW.SUPPLIERS s CROSS JOIN days d
  LEFT JOIN outage_events o ON o.DAY_INDEX = d.DAY_INDEX AND o.REGION = s.REGION
), reviews AS (
  SELECT *,
         IFF(DAYS_SINCE_REVIEW = 0, 1, 0) AS REVIEW_DUE,
         IFF(DAYS_SINCE_REVIEW = 0 AND U_DONE < REVIEW_RETURN_PROB, 1, 0) AS REVIEW_DONE,
         -- Delivery drift rises between supplier performance reviews; weak follow-up carries it over.
         DAYS_SINCE_REVIEW / REVIEW_INTERVAL_DAYS + (1 - REVIEW_RETURN_PROB) AS DRIFT
  FROM base
), activity AS (
  SELECT *,
         CASE WHEN U_MISS < LEAST(0.5, BASE_MISS_RATE * (0.4 + 1.6 * DRIFT) * (1 + 1 / (1 + PROGRAM_YEARS))) / 4 THEN 2
              WHEN U_MISS < LEAST(0.5, BASE_MISS_RATE * (0.4 + 1.6 * DRIFT) * (1 + 1 / (1 + PROGRAM_YEARS))) THEN 1
              ELSE 0 END AS MISS_COUNT
  FROM reviews
), checks AS (
  SELECT *,
         -- Goods-receipt checks confirm about 80% of misses; the rest stays undetected.
         IFF(OUTAGE_EVENT, 0, IFF(U_DETECT < 0.80, MISS_COUNT, 0)) AS CONFIRMED_COUNT,
         -- False-positive flags (cleared on receipt): higher where ASN data is weaker.
         IFF(OUTAGE_EVENT, 1, IFF(U_FP < CASE CATEGORY WHEN 'Substrate supplier' THEN 0.15
                                              WHEN 'Specialty chemicals supplier' THEN 0.14
                                              WHEN 'Test consumables supplier' THEN 0.12
                                              WHEN 'Lead frame supplier' THEN 0.09 ELSE 0.06 END, 1, 0)) AS FALSE_POSITIVE_COUNT
  FROM activity
), measured AS (
  SELECT *,
         CONFIRMED_COUNT + FALSE_POSITIVE_COUNT AS FLAG_COUNT,
         ROUND(CASE CATEGORY WHEN 'Bonding wire supplier' THEN 6 WHEN 'Lead frame supplier' THEN 9
                             WHEN 'Substrate supplier' THEN 5 WHEN 'Specialty chemicals supplier' THEN 4 ELSE 7 END
               * SIZE_FACTOR * (0.7 + 0.6 * U_SHIP)) AS SHIPMENT_COUNT,
         -- Thousand units (spools, strips, panels, containers, sockets) per inbound shipment.
         CASE CATEGORY WHEN 'Bonding wire supplier' THEN 12 WHEN 'Lead frame supplier' THEN 85
                       WHEN 'Substrate supplier' THEN 40 WHEN 'Specialty chemicals supplier' THEN 6
                       ELSE 18 END
           * (0.9 + 0.2 * U_NOISE) AS AVG_SHIPMENT_KUNITS,
         LEAST(95, BASE_LATE_PCT + 6 * DRIFT + 9 * MISS_COUNT + 2 * U_NOISE) AS LATE_SHARE
  FROM checks
)
SELECT ENTITY_ID || '-' || TO_CHAR(EVENT_DATE, 'YYYYMMDD') AS EVENT_ID,
       ENTITY_ID, EVENT_DATE,
       SHIPMENT_COUNT,
       ROUND(SHIPMENT_COUNT * AVG_SHIPMENT_KUNITS * (1 - LATE_SHARE / 100), 2) AS ONTIME_KUNITS,
       ROUND(SHIPMENT_COUNT * AVG_SHIPMENT_KUNITS, 2) AS SHIPPED_KUNITS,
       FLAG_COUNT, CONFIRMED_COUNT,
       IFF(CONFIRMED_COUNT > 0 AND U_HOLD < 0.5, 1, 0) AS LOTS_QUARANTINED,
       CASE WHEN FLAG_COUNT = 0 THEN 'None'
            WHEN OUTAGE_EVENT THEN 'Customs clearance system outage'
            WHEN CATEGORY = 'Bonding wire supplier' THEN IFF(U_SIG < 0.6, 'ASN quantity mismatch', 'Certificate of analysis missing')
            WHEN CATEGORY = 'Lead frame supplier' THEN IFF(U_SIG < 0.55, 'Plating spec deviation', 'Carrier pickup missed')
            WHEN CATEGORY = 'Substrate supplier' THEN IFF(U_SIG < 0.45, 'Capacity allocation cut', IFF(U_SIG < 0.8, 'Commit date slipped', 'ASN quantity mismatch'))
            WHEN CATEGORY = 'Specialty chemicals supplier' THEN IFF(U_SIG < 0.55, 'Shelf-life window short', 'Hazardous goods permit pending')
            ELSE IFF(U_SIG < 0.5, 'Unannounced tooling change', 'Commit date slipped') END AS RISK_SIGNAL,
       REVIEW_DUE, REVIEW_DONE,
       ROUND(0.4 + 1.8 * DRIFT + 3.2 * MISS_COUNT + U_NOISE * 0.9, 2) AS ASN_VARIANCE_PCT,
       ROUND(LATE_SHARE, 1) AS LATE_PCT,
       CURRENT_TIMESTAMP() AS LOADED_AT
FROM measured;

-- Part qualification snapshot per supplier: active part numbers, parts with a
-- qualified second source on file, and second-source qualifications in progress.
CREATE TABLE RAW.PART_QUALIFICATION AS
WITH sized AS (
  SELECT ID, CATEGORY,
         ROUND(CASE CATEGORY WHEN 'Bonding wire supplier' THEN 40 WHEN 'Lead frame supplier' THEN 120
                             WHEN 'Substrate supplier' THEN 260 WHEN 'Specialty chemicals supplier' THEN 90 ELSE 180 END
               * (0.6 + MOD(ABS(HASH(ID, 'mysc-parts')), 1000000) / 1e6 * 0.8)) AS PARTS,
         CASE CATEGORY WHEN 'Bonding wire supplier' THEN 0.78 WHEN 'Lead frame supplier' THEN 0.66
                       WHEN 'Substrate supplier' THEN 0.31 WHEN 'Specialty chemicals supplier' THEN 0.44 ELSE 0.57 END
           + MOD(ABS(HASH(ID, 'mysc-second')), 1000000) / 1e6 * 0.25 AS SECOND_SOURCE_SHARE
  FROM RAW.SUPPLIERS
)
SELECT ID AS ENTITY_ID,
       CASE CATEGORY WHEN 'Bonding wire supplier' THEN 'Wire alloy qualification'
                     WHEN 'Lead frame supplier' THEN 'Lead frame design qualification'
                     WHEN 'Substrate supplier' THEN 'Substrate build qualification'
                     WHEN 'Specialty chemicals supplier' THEN 'Material change qualification'
                     ELSE 'Consumable fit qualification' END AS EVIDENCE_TYPE,
       PARTS AS REQUIRED_QTY,
       LEAST(PARTS, ROUND(PARTS * SECOND_SOURCE_SHARE)) AS ON_FILE_QTY,
       ROUND((PARTS - LEAST(PARTS, ROUND(PARTS * SECOND_SOURCE_SHARE))) * MOD(ABS(HASH(ID, 'mysc-pending')), 1000000) / 1e6 * 0.5) AS PENDING_QTY,
       CURRENT_DATE() AS SNAPSHOT_DATE
FROM sized;
