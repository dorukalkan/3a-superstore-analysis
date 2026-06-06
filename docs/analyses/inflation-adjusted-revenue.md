---
icon: lucide/turkish-lira
title: Revenue Performance & Inflation Analysis
description: Inflation-adjusted real revenue vs. nominal revenue performance
--- 

# Revenue Performance & Inflation Analysis

![Power BI Revenue Performance Dashboard](../assets/revenue_dashboard.png)
/// caption
Power BI dashboard on nominal vs. real revenue performance
///

## Overview

This analysis focuses on a core business question: did 3A Superstore’s revenue actually grow, or did nominal growth mainly reflect inflation-driven price increases?

The dataset covers a Turkish supermarket chain over a high-inflation period. In that context, looking only at nominal revenue can be misleading. A business may appear to be growing because the amount of money collected at checkout increases, while the real purchasing power of that revenue declines.

To separate these effects, I compared:

- Nominal revenue: the actual TRY amount collected from sales.
- Real revenue: revenue adjusted by CPI to account for inflation.
- Volume metrics: customers, orders, and units sold.
- Product price changes: realized item-level price changes over time.

The goal was to distinguish between true business growth and inflation-driven nominal growth.

---

## Dashboard

Revenue Performance & Inflation Analysis Dashboard

The dashboard summarizes the inflation story from several angles: CPI trend, nominal vs real revenue, annual revenue comparison, customer/order/unit changes, and product-level price increases.

---

## Methodology

The analysis uses monthly CPI data from TCMB EVDS[^evds] and joins it to monthly revenue aggregates created in dbt.

The transformation pipeline follows this structure:

1. Clean and standardize raw sales tables.
2. Aggregate order-level revenue to monthly revenue.
3. Prepare monthly CPI index values.
4. Convert nominal revenue into inflation-adjusted real revenue.
5. Create BI-ready marts for Power BI.
6. Validate the revenue story with volume metrics and item-level price changes.

The CPI series is an index, so the original 2003 baseline is not directly meaningful for revenue interpretation. What matters is the ratio between CPI levels. Real revenue is calculated using a CPI adjustment factor:

text real_revenue = nominal_revenue × CPI_base_month / CPI_current_month 

In the dashboard, January 2021 is used as the base period. This makes the first month of the analysis equal for nominal and real revenue, then shows how the two series diverge over time.

---

## Key Findings

### 1. Nominal revenue increased, but real revenue declined

Across the analysis period, total nominal revenue reached approximately 13.11bn TRY. However, after inflation adjustment, total real revenue was approximately 7.87bn TRY.

This shows that the business collected more money in nominal terms, but that money represented significantly less purchasing power after accounting for inflation.

The main trend chart shows this clearly: nominal revenue follows an upward path, while inflation-adjusted revenue declines over time. In other words, revenue appears to grow on paper, but its real economic value erodes.

---

### 2. CPI increased sharply during the period

The CPI index rose dramatically over the analysis period, reaching roughly 263 on the dashboard’s January 2021 = 100 scale. This means the general price level rose by more than 160% relative to the start of the dataset.

This inflationary environment is the main reason nominal revenue alone is not enough to evaluate performance.

---

### 3. Volume metrics did not explain nominal revenue growth

To check whether nominal revenue growth came from actual business expansion, I compared customer count, order count, and units sold.

The result was not consistent with strong volume growth:

- Customer count changed only slightly.
- Units sold declined by around 3.6%.
- Order count declined by around 3.7%.

This means the nominal revenue increase was not mainly driven by more customers, more orders, or more units sold. The volume side of the business remained broadly stable or slightly weaker.

---

### 4. Product prices increased substantially

The item-level analysis supports the inflation hypothesis. Across thousands of products, realized paid prices increased substantially over the period.

The dashboard shows average paid price increases above 100% across major product categories. For example, hot beverages showed one of the highest increases, at around 121%, while several other categories such as cleaning, produce, baby products, and dairy also showed strong price growth.

This helps explain why nominal revenue increased despite weak volume growth: the business was selling products at higher nominal prices, but those higher prices did not translate into stronger real revenue.

---

## Business Interpretation

The analysis suggests that 3A Superstore’s revenue growth was largely inflation-driven rather than volume-driven.

A simplified interpretation is:

text Nominal revenue increased → but CPI increased sharply → real revenue declined → customers, orders, and units did not materially increase → product prices rose substantially → therefore nominal growth was mostly caused by inflation and price increases 

This is an important distinction for business performance analysis. If management only tracks nominal revenue, the business may appear healthy. But after adjusting for inflation, the company’s revenue performance looks weaker.

The key takeaway is:

> 3A Superstore collected more TRY over time, but earned less in real purchasing-power terms.

---

## Business Recommendation

The main strategic implication is that revenue growth needs to be evaluated against inflation, not just against previous nominal sales.

To protect real revenue, the business would need to pursue strategies that generate growth above inflation, such as:

- improving customer retention and purchase frequency,
- increasing basket value through targeted promotions,
- optimizing product mix toward higher-margin or more resilient categories,
- improving regional performance in weaker branches,
- monitoring real revenue and real average order value as standard KPIs.

For high-inflation markets, nominal revenue should not be treated as the primary success metric. Real revenue, volume, and price-adjusted KPIs provide a more reliable view of business health.

---

## Technical Implementation

This analysis was built as part of a team analytics project using:

- BigQuery for raw data storage and querying,
- dbt for staging, intermediate models, CPI adjustment logic, and BI-ready marts,
- Power BI for dashboarding,
- Python notebooks for exploration and validation.

My dbt work focused on the revenue and inflation path:

- CPI seed preparation from TCMB EVDS data,
- monthly CPI staging and intermediate models,
- monthly nominal and real revenue facts,
- indexed revenue trend marts,
- KPI marts for dashboard cards,
- product price validation marts.

The final Power BI report uses dbt-created marts rather than ad hoc dashboard logic, keeping the revenue definitions reproducible and traceable.

---

## Summary

This analysis shows why inflation adjustment is essential when evaluating revenue in high-inflation environments.

Nominal revenue increased, but real revenue declined. Customer, order, and unit metrics did not show enough growth to explain the nominal increase. Product-level price changes confirmed that the revenue increase was mainly price-driven.

The final conclusion is straightforward:

> The supermarket looked larger in nominal terms, but its real revenue performance weakened under inflation.

[^evds]: TCMB EVDS is the Electronic Data Delivery System of the Central Bank of the Republic of Türkiye. It provides access to official economic time series, including CPI data. See the [EVDS portal](https://evds3.tcmb.gov.tr) and [EVDS documentation](https://evds3.tcmb.gov.tr/dokumanlar) for API and usage details.
