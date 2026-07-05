# Weather Data Pipeline

An end-to-end, cloud-native data pipeline that extracts weather data from a public API, lands it in cloud storage, loads it into a warehouse, and transforms it into a tested analytical model — following the modern ELT pattern.

Built to production patterns: **idempotent loads, incremental processing, data quality tests, and orchestration with dependency management.**

---

## Architecture

```
  Open-Meteo API
        │
        ▼
  AWS Lambda  ──────────►  Amazon S3
  (scheduled via          (raw JSON,
   EventBridge, daily)     partitioned by date)
        │
        ▼
  Snowflake (RAW schema)  ◄──── COPY INTO (orchestrated by Airflow)
        │
        ▼
  dbt  ──►  staging (view)  ──►  star schema (fact + dimensions)
        │                        with tests: not_null, unique,
        ▼                        relationships
  Snowflake (ANALYTICS schema)
```

**Flow:** A scheduled AWS Lambda pulls hourly weather for several cities and lands the raw JSON in S3, partitioned by date. Airflow orchestrates loading that raw data into Snowflake via `COPY INTO`. dbt then transforms the raw JSON into a clean star schema — a staging layer that flattens the nested API response, and fact/dimension tables — with automated data quality tests between layers.

---

## Tech Stack

| Layer | Tool | Why |
|---|---|---|
| Extraction | Python + AWS Lambda | Serverless, scheduled pulls with no server to manage |
| Scheduling | Amazon EventBridge | Triggers the Lambda daily |
| Raw storage | Amazon S3 | Cheap, immutable landing zone; partitioned by date |
| Warehouse | Snowflake | Separates storage & compute; scales independently |
| Transformation | dbt | SQL transformations with version control, testing, and lineage |
| Orchestration | Apache Airflow | Dependency management, scheduling, failure handling |
| Containerization | Docker | Reproducible environments for dbt and Airflow |

---

## Key Engineering Decisions

**Idempotency at multiple layers.** Re-running any stage never produces duplicates. The S3 extractor overwrites per-date keys; `COPY INTO` tracks already-loaded files; and the dbt fact model deduplicates with a window function (`qualify row_number() ... = 1`, keeping the most recent record per key). This means retries after failure are always safe — a core requirement for reliable pipelines.

**Incremental loading.** The fact model is materialized incrementally: instead of rebuilding all history every run, it processes only rows newer than the current watermark (`max(loaded_at)`) and merges them on a surrogate key. This keeps runs fast and cheap as data volume grows.

**Raw-immutability for recoverability.** Raw JSON is kept untouched in S3 and the `RAW` schema. Because the source of truth is preserved, the entire warehouse can be rebuilt from raw if a transformation bug is found — the reason the "land raw first" principle exists.

**Star schema modeling.** Data is modeled as one fact table (`fct_weather_hourly`, grain: one row per city per hour) surrounded by dimension tables (`dim_city`, `dim_date`), so analysts can slice metrics by any dimension with simple, fast queries.

**Data quality as a gate.** dbt tests (`not_null`, `unique`, `relationships`) run between layers and catch problems — duplicate keys, orphaned foreign keys, missing values — before bad data reaches the analytical layer.

---

## Data Model

**`fct_weather_hourly`** (fact) — grain: one row per city per hour
- `weather_key` (surrogate key), `city`, `date_day`, `observed_at`
- measures: `temperature_c`, `humidity_pct`, `wind_speed`, `precipitation`

**`dim_city`** (dimension) — one row per city: name, latitude, longitude, timezone

**`dim_date`** (dimension) — one row per calendar day: year, month, day, day name

---

## Repository Structure

```
.
├── lambda_function.py       # AWS Lambda extractor (API → S3)
├── api.py                   # Local version of the extractor
├── dbt/
│   ├── models/
│   │   ├── staging/         # stg_weather: flattens raw JSON
│   │   └── marts/           # fct_weather_hourly, dim_city, dim_date + tests
│   ├── dbt_project.yml
│   └── profiles.yml
├── dbt.Dockerfile           # Runs dbt in a container
└── airflow/
    ├── dags/                # weather_pipeline DAG
    └── docker-compose.yaml  # Airflow stack
```

---

## Concepts Demonstrated

- ELT architecture (load raw, transform in-warehouse)
- Idempotent and incremental data loading
- Entity/grain modeling (star schema, surrogate keys)
- Data quality testing and referential integrity
- Pipeline orchestration with dependency management
- Key-pair authentication for warehouse connections
- Serverless extraction with scheduled triggers

---

## Notes

This is a learning project built to practice production data engineering patterns end to end. The extraction and load layers are fully automated (Lambda on a schedule; Airflow-orchestrated `COPY INTO`); dbt transformations run against Snowflake and can be triggered on a schedule or wired into the Airflow DAG via a `BashOperator` / dbt task group.