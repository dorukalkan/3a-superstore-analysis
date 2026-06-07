---
icon: lucide/package-search
title: Analytics Marts
description: dbt mart models documentation
---

# Analytics-Ready dbt Marts

The mart layer contains the final tables used by Power BI dashboards, notebooks,
and the project writeup. These models are shaped around business questions:
monthly revenue performance, inflation-adjusted metrics, product price changes,
regional contribution, category distribution, customer health, and retention.

Compared with the intermediate layer, marts are closer to dashboard contracts.
They expose stable grains, named metrics, and filtered windows that match the
analysis pages.

## Revenue and Inflation Marts

| Model | Grain | Main role |
| --- | --- | --- |
| `fct_monthly_revenue` | One row per sales month | Monthly nominal revenue, real revenue in January 2021 TRY, CPI metrics, order count, customer count, units sold, average order value, and January 2021 revenue indexes. |
| `mart_revenue_trend_monthly` | One row per month from January 2021 through June 2023 | Slim dashboard trend table for nominal revenue, real revenue, and CPI index lines. |
| `mart_revenue_story_kpis` | One row per KPI metric | Compares January 2021 with June 2023 for revenue, CPI, orders, units, and customers. |

These marts support the [Revenue Performance & Inflation Analysis](../analyses/inflation-adjusted-revenue.md)
page. They make the central comparison explicit: nominal revenue can rise while
real revenue, volume, and purchasing-power adjusted metrics tell a weaker
business story.

## Product Price Marts

| Model | Grain | Main role |
| --- | --- | --- |
| `mart_product_price_trend_monthly` | One row per month | Portfolio-level paid price medians, real price medians, source-price diagnostics, and January 2021 price indexes. |
| `mart_product_price_story_kpis` | One row | Endpoint KPI table comparing January 2021 with June 2023 product price movement and eligible-item coverage. |
| `mart_product_category_price_trend_monthly` | One row per category/month | Category-level price trend and ranking by effective paid price increase since January 2021. |
| `mart_product_category_price_increase_bar` | One row per top-level category | June 2023 bar-chart mart for category price increases since January 2021. |

These marts validate whether nominal revenue growth was supported by actual
volume growth or by rising realized prices. They also give the category pages a
reusable price-change view instead of relying only on raw revenue totals.

## Branch and Regional Marts

| Model | Grain | Main role |
| --- | --- | --- |
| `fct_daily_branch_revenue` | One row per branch/date | Daily branch revenue, order count, customer count, units sold, average order value, region, city, and branch town. |
| `mart_category_region_distribution` | One row per region/city/category combination | Regional and category contribution metrics: orders, unique products, quantity, revenue, and average basket value. |

These tables support regional revenue analysis and category distribution views.
They keep geographic and category reporting at a business-friendly grain while
still tracing back to order-line data.

## Customer Marts

| Model | Grain | Main role |
| --- | --- | --- |
| `mart_customer_360` | One row per customer | Customer lifetime revenue, total orders, tenure, recency, active months, average order value, average basket quantity, repeat/high-value flags, value segment, and lifecycle stage. |
| `mart_customer_rfm` | One row per customer | RFM quintile scores, combined RFM score, total score, and segment labels such as Champions, Loyal Customers, At Risk, and Potential Loyalist. |

These marts support the customer health, retention, and growth analyses. They
translate transaction history into customer-level signals that can be used for
retention prioritization, customer value segmentation, and churn-risk
interpretation.

## Dashboard and Analysis Mapping

| Analysis area | Primary marts |
| --- | --- |
| Inflation-adjusted revenue | `fct_monthly_revenue`, `mart_revenue_trend_monthly`, `mart_revenue_story_kpis`, product price marts |
| Sales and revenue insights | `fct_monthly_revenue`, `fct_daily_branch_revenue` |
| Customer growth opportunities | `mart_customer_360`, `mart_customer_rfm`, enriched order/product models |
| Customer health and retention | `mart_customer_360`, `mart_customer_rfm` |
| Regional revenue and category performance | `fct_daily_branch_revenue`, `mart_category_region_distribution` |
| Category trends and price movement | `mart_category_region_distribution`, `mart_product_category_price_trend_monthly`, `mart_product_category_price_increase_bar` |

## Testing and Trust

The mart layer is protected by custom tests for revenue reconciliation, real
revenue math, CPI scenario behavior, base-index logic, endpoint windows, KPI
calculation, product price grain, and category price eligibility. These tests
are especially important because the mart tables are the definitions consumed by
dashboards and project writeups.
