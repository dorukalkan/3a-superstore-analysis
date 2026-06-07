---
icon: lucide/package-open
title: Intermediate Models
description: dbt intermediate models documentation
---

# Intermediate dbt Models

The intermediate layer turns cleaned staging tables into reusable analytical
building blocks. This is where the project defines the logic that should be
shared across notebooks, Power BI dashboards, and final mart models: revenue
reconciliation, CPI adjustment factors, item pricing, customer enrichment, and
safe branch joins.

The goal of this layer is reuse. Instead of calculating the same metric in
multiple dashboards, the project defines it once in dbt and then builds marts on
top of that definition.

## Core Business Logic

| Area | Model | Grain | Main role |
| --- | --- | --- | --- |
| Revenue | `int_order_revenue` | One row per order | Combines order headers with line totals, units sold, line item count, month/year/quarter keys, and revenue reconciliation fields. |
| Revenue | `int_branch_dim` | One row per branch | Collapses branch coverage rows into a safe branch dimension with region, city, branch town, and covered-town count. |
| Inflation | `int_cpi_monthly` | One row per CPI month | Calculates CPI month-over-month and year-over-year rates, the January 2021 base CPI, the inflation adjustment factor, and a January 2021 = 100 CPI index. |
| Product pricing | `int_order_line_pricing` | One row per priced order line | Filters positive price/quantity rows and calculates effective paid unit price, real paid unit price, and source-vs-paid price variance. |
| Product pricing | `int_item_month_pricing` | One row per item/month | Aggregates line pricing into item-month price medians, real price medians, units sold, and line counts. |
| Enrichment | `int_orderdetail_order_enriched` | One row per order line | Adds order date, customer, branch, period fields, order quantity, item count, and line revenue share to order details. |
| Enrichment | `int_orderdetail_order_customer_enriched` | One row per order line | Adds customer profile fields plus customer age, lifetime revenue, recency, tenure, active months, and order sequence metrics. |
| Enrichment | `int_orderdetail_order_product_enriched` | One row per order line | Adds product category hierarchy and branch geography for regional and category analysis. |

`int_orderdetail_order_branch_enriched` is also available as a branch-enriched
line-item helper. Its role overlaps with the regional/category path, so the
public marts generally rely on the more targeted branch dimension and
product-enriched models.

## Why This Layer Matters

- Revenue definitions are centralized before they reach Power BI or notebooks.
- CPI math is reproducible and testable instead of being calculated inside a
  dashboard.
- Branch coverage rows are reduced into a safe branch dimension before joining
  to order-level facts.
- Product price logic distinguishes source unit price from realized paid unit
  price, which is important for validating the inflation story.
- Customer, product, and branch enrichment models let different analysis pages
  reuse the same analytical base.

## Validation Coverage

Custom dbt tests focus on the parts of the model graph where silent mistakes
would materially change the analysis:

- CPI base-month, cumulative-index, month-over-month, and year-over-year math.
- Effective paid unit price calculations and positive price filters.
- Item-month pricing grain.
- Monthly revenue reconciliation between order headers, line totals, and CPI
  adjusted metrics.

These checks make the downstream dashboards easier to trust because the key math
is validated before it reaches the mart layer.
