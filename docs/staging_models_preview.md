# Staging Models Preview

Snapshot date: 2026-05-21

This document records the current staging-layer state in BigQuery dataset
`superstore-analysis-496710.dbt_doruk`, plus staging models that exist in the
repo but are not currently present in that dataset.

Commands used:

```bash
bq query --use_legacy_sql=false --location=EU --format=prettyjson \
  'select table_name, column_name, data_type, is_nullable, ordinal_position
   from `superstore-analysis-496710.dbt_doruk.INFORMATION_SCHEMA.COLUMNS`
   where table_name in (
     "stg_orders",
     "stg_order_details",
     "stg_raw_customers",
     "stg_branch",
     "stg_raw_categories"
   )
   order by table_name, ordinal_position'
```

```bash
bq query --use_legacy_sql=false --location=EU --format=prettyjson \
  'select "stg_branch" as table_name, count(*) as row_count
   from `superstore-analysis-496710.dbt_doruk.stg_branch`
   union all
   select "stg_order_details", count(*)
   from `superstore-analysis-496710.dbt_doruk.stg_order_details`
   union all
   select "stg_orders", count(*)
   from `superstore-analysis-496710.dbt_doruk.stg_orders`
   order by table_name'
```

Sample rows use deterministic ordering:

- `stg_branch`: `order by branch_id, town limit 5`
- `stg_orders`: `order by order_id limit 5`
- `stg_order_details`: `order by order_detail_id limit 5`

## Current BigQuery Staging Objects

| Table | Type | Row count | Notes |
| --- | --- | ---: | --- |
| `stg_branch` | View | 957 | One row per branch/town coverage row, not one row per branch. |
| `stg_order_details` | View | 51,185,032 | Order line grain. |
| `stg_orders` | View | 10,235,193 | Order header grain. |
| `stg_orders_test` | View | Not counted | Present in BigQuery, but not represented by a current source SQL file in `superstore/models/staging`. |

## `stg_branch`

Source file: `superstore/models/staging/stg_branch.sql`

Grain: branch coverage row. A `branch_id` can appear multiple times for
different covered towns, so this table should not be joined directly to order
facts unless the desired grain is confirmed.

### Schema

| Ordinal | Column | Data type | Nullable |
| ---: | --- | --- | --- |
| 1 | `branch_id` | `STRING` | YES |
| 2 | `region` | `STRING` | YES |
| 3 | `city` | `STRING` | YES |
| 4 | `town` | `STRING` | YES |
| 5 | `branch_town` | `STRING` | YES |
| 6 | `latitude` | `NUMERIC` | YES |
| 7 | `longitude` | `NUMERIC` | YES |

### Sample Rows

| branch_id | region | city | town | branch_town | latitude | longitude |
| --- | --- | --- | --- | --- | ---: | ---: |
| `11-AD1` | Akdeniz | Adana | Ceyhan | Ceyhan | 37.0317 | 35.82275 |
| `11-AD1` | Akdeniz | Adana | Yumurtalik | Ceyhan | 36.766667 | 35.783333 |
| `11-AD2` | Akdeniz | Adana | Aladağ | Kozan | 37.546379 | 35.402962 |
| `11-AD2` | Akdeniz | Adana | Feke | Kozan | 37.819918 | 35.912484 |
| `11-AD2` | Akdeniz | Adana | Kozan | Kozan | 37.45 | 35.8 |

## `stg_orders`

Source file: `superstore/models/staging/stg_orders.sql`

Grain: one row per order header.

### Schema

| Ordinal | Column | Data type | Nullable |
| ---: | --- | --- | --- |
| 1 | `order_id` | `INT64` | YES |
| 2 | `branch_id` | `STRING` | YES |
| 3 | `customer_id` | `INT64` | YES |
| 4 | `order_datetime` | `DATETIME` | YES |
| 5 | `order_date` | `DATE` | YES |
| 6 | `customer_name` | `STRING` | YES |
| 7 | `total_basket` | `NUMERIC` | YES |

### Sample Rows

| order_id | branch_id | customer_id | order_datetime | order_date | customer_name | total_basket |
| ---: | --- | ---: | --- | --- | --- | ---: |
| 1 | `230-HA1` | 20743 | 2022-02-20T00:00:00 | 2022-02-20 | Merve Yücel | 10.4 |
| 2 | `734-İS1` | 63845 | 2021-11-21T00:00:00 | 2021-11-21 | Damla Burcu Yıldırım | 25.6 |
| 3 | `681-DÜ1` | 33206 | 2022-03-21T00:00:00 | 2022-03-21 | Melike Ergin | 1248.37 |
| 4 | `131-HA3` | 69767 | 2021-08-02T00:00:00 | 2021-08-02 | Can Çelik | 1801.88 |
| 5 | `224-ER1` | 2692 | 2021-03-23T00:00:00 | 2021-03-23 | Rabia Çakmak | 219.17 |

## `stg_order_details`

Source file: `superstore/models/staging/stg_order_details.sql`

Grain: one row per order line item.

### Schema

| Ordinal | Column | Data type | Nullable |
| ---: | --- | --- | --- |
| 1 | `order_id` | `INT64` | YES |
| 2 | `order_detail_id` | `INT64` | YES |
| 3 | `item_id` | `INT64` | YES |
| 4 | `item_code` | `INT64` | YES |
| 5 | `amount` | `INT64` | YES |
| 6 | `unit_price` | `FLOAT64` | YES |
| 7 | `total_price` | `FLOAT64` | YES |

### Sample Rows

| order_id | order_detail_id | item_id | item_code | amount | unit_price | total_price |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 1 | 25548 | 41599 | 2 | 5.52 | 10.4 |
| 2 | 2 | 18955 | 33434 | 8 | 4.32 | 25.6 |
| 3 | 3 | 22652 | 35047 | 2 | 322.25 | 574.26 |
| 3 | 4 | 12228 | 5559 | 6 | 39.6 | 217.44 |
| 3 | 5 | 23218 | 45152 | 1 | 6.0 | 5.43 |

## Repo Staging Models Not Present in BigQuery

These models are present in `superstore/models/staging`, but they were not
returned by `INFORMATION_SCHEMA.TABLES` for `dbt_doruk` during this preview.
They should be built or investigated before depending on them from
intermediate models.

### `stg_raw_customers`

Source file: `superstore/models/staging/stg_raw_customers.sql`

Expected columns from the model SQL:

| Column | Expected type from SQL expression | Notes |
| --- | --- | --- |
| `user_id` | `STRING` | Parsed from `string_field_0`; not cast to integer. |
| `email` | `STRING` | Parsed from `string_field_0`. |
| `full_name` | `STRING` | Parsed from `string_field_0`. |
| `status` | `STRING` | Parsed from `string_field_0`; not cast to integer/boolean. |
| `gender` | `STRING` | Parsed from `string_field_0`. |
| `birth_date` | `STRING` | Parsed from `string_field_0`; not cast to date. |
| `region` | `STRING` | Parsed from `string_field_0`. |
| `city` | `STRING` | Parsed from `string_field_0`. |
| `town` | `STRING` | Parsed from `string_field_0`. |
| `district` | `STRING` | Parsed from `string_field_0`. |
| `address` | `STRING` | Parsed from `string_field_0`. |

No BigQuery row preview is available until the model exists in
`dbt_doruk`.

### `stg_raw_categories`

Source file: `superstore/models/staging/stg_raw_categories.sql`

Expected columns from the model SQL:

| Column | Notes |
| --- | --- |
| `itemid` | Raw category item identifier. |
| `category1` | Top-level category. |
| `category1_id` | Top-level category identifier. |
| `category2` | Second-level category. |
| `category2_id` | Second-level category identifier. |
| `category3` | Third-level category. |
| `category3_id` | Third-level category identifier. |
| `category4` | Fourth-level category. |
| `category4_id` | Fourth-level category identifier. |
| `brand` | Product brand. |
| `itemcode` | Product item code. |
| `itemname` | Product name. |

No BigQuery row preview is available until the model exists in
`dbt_doruk`.

## Notes for Intermediate Modeling

- Use `stg_orders` as the order-header fact source.
- Use `stg_order_details` as the line-item fact source.
- Do not directly join `stg_orders` to `stg_branch` for order-level metrics
  unless branch rows are first reduced to one row per `branch_id`.
- Customer and category enrichment is not available from the current deployed
  staging layer. Build or fix `stg_raw_customers` and `stg_raw_categories`
  before using them in intermediate models.
