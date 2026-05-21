# dbt & bq CLI commands

dbt and BigQuery CLI commands to run & inspect models.

Move to the dbt project folder from repo root
```bash
cd ~/dev/3a-superstore-analysis/superstore
```

Validate dbt parsing
```bash
uv run dbt parse
```

Build models
```bash
uv run dbt build
```

Build specific models
```bash
uv run dbt build --select fct_daily_branch_revenue
```

List all staging models
```bash
uv run dbt ls --select staging
```

Preview table schema with BigQuery CLI
```bash
bq show \
  --schema \
  --format=prettyjson \
  superstore-analysis-496710:dbt_doruk.stg_orders
```

Preview table rows
```bash
bq query \
  --use_legacy_sql=false \
  --location=EU \
  --format=prettyjson \
  'select * from `superstore-analysis-496710.dbt_doruk.stg_orders` limit 10'
```

Get column names & data types of staging tables
```bash
bq query \
  --use_legacy_sql=false \
  --location=EU \
  --format=prettyjson \
  '
  select
    table_name,
    column_name,
    data_type,
    is_nullable,
    ordinal_position
  from `superstore-analysis-496710.dbt_doruk.INFORMATION_SCHEMA.COLUMNS`
  where table_name in (
    "stg_orders",
    "stg_order_details",
    "stg_raw_customers",
    "stg_branch",
    "stg_raw_categories"
  )
  order by table_name, ordinal_position
  '
```