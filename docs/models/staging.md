---
icon: lucide/arrows-up-from-line
title: Staging Models
description: dbt staging models documentation
---

# Staging dbt Models

The staging layer is the first modeled version of the raw data. Its job is to
make the source tables predictable: column names are standardized, types are
cast, Turkish decimal-comma money fields are parsed, and the original source
grain is preserved for later modeling.

These models are intentionally simple. They do not answer business questions on
their own; they create clean inputs for the intermediate and mart layers.

## Layer Responsibilities

- Rename raw source fields into analytics-friendly names.
- Cast order, customer, branch, item, date, money, and coordinate fields.
- Preserve the raw business grain instead of aggregating too early.
- Stage the TCMB EVDS CPI seed at monthly grain.
- Add basic dbt tests for identifiers, required fields, uniqueness, and CPI
  validity.

## Model Summary

| Model | Grain | Main role |
| --- | --- | --- |
| `stg_orders` | One row per order header | Standardizes order IDs, branch/customer IDs, order dates, customer name, and nominal basket value. |
| `stg_order_details` | One row per order line | Standardizes item IDs, quantities, source unit prices, and paid line totals. |
| `stg_branch` | One row per branch/town coverage row | Cleans branch geography, branch towns, covered towns, and latitude/longitude values. |
| `stg_raw_customers` | One row per customer | Parses semicolon-delimited raw customer records into profile and address fields. |
| `stg_raw_categories` | One row per product item | Exposes product category hierarchy, brand, item code, and item name. |
| `stg_cpi_monthly` | One row per CPI month | Stages monthly TCMB EVDS CPI index values from the dbt seed. |

## Important Grain Notes

`stg_orders` and `stg_order_details` stay separate because they represent
different facts: order headers and order lines. This keeps basket-level revenue
and line-level product behavior available without forcing one early definition.

`stg_branch` is a coverage table, not a one-row-per-branch dimension. A branch
can appear multiple times for different covered towns, so downstream branch fact
models use `int_branch_dim` when they need a safe one-row-per-branch join.

`stg_cpi_monthly` is monthly by design. Later revenue and product-pricing models
join to CPI through month keys so nominal values can be converted into January
2021 Turkish lira.

## Downstream Use

| Analysis path | Staging inputs |
| --- | --- |
| Revenue and inflation analysis | `stg_orders`, `stg_order_details`, `stg_cpi_monthly` |
| Product price and category analysis | `stg_order_details`, `stg_orders`, `stg_raw_categories`, `stg_cpi_monthly` |
| Customer health, growth, and retention analysis | `stg_orders`, `stg_order_details`, `stg_raw_customers` |
| Regional revenue and branch analysis | `stg_orders`, `stg_order_details`, `stg_branch`, `stg_raw_categories` |

## Validation Focus

The staging tests check that key identifiers and required fields are present,
that unique source entities remain unique where expected, and that CPI values
are valid before they are used in inflation-adjusted metrics.
