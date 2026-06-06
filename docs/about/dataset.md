---
icon: lucide/chart-column-increasing
---

# Dataset

This project uses the Kaggle dataset [3A Superstore (Market Orders Data-CRM)](https://www.kaggle.com/datasets/cemeraan/3a-superstore), published by Kaggle user `cemeraan`.

The dataset represents a large retail supermarket environment with order, customer, branch, and product-category data. It is structured well for business analytics because it includes both transaction-level sales records and the reference tables needed to explain those sales by customer, geography, product, and time.

## What It Contains

The project works with five main raw tables:

| Table | Role in the analysis |
| --- | --- |
| `orders` | Order headers, including order date, branch, customer, and total basket value. |
| `order_details` | Order line items, including product identifiers, quantity, unit price, and line total. |
| `customers` | Customer attributes used for CRM, retention, and segmentation analysis. |
| `branch` | Store and geographic coverage data, including region, city, town, and coordinates. |
| `categories` | Product metadata, including brand and multi-level product category hierarchy. |

In our BigQuery and dbt workflow, these tables are cleaned into staging models, enriched into intermediate analytical models, and aggregated into marts for revenue, inflation, product pricing, branch performance, customer analysis, and dashboard reporting.

## How We Used It

The dataset supports several business questions:

- How did revenue change over time?
- Did nominal revenue growth reflect real business growth, or mostly inflation?
- Which regions, branches, and categories contributed most to sales?
- How did product prices change across the analysis period?
- Which customer and basket patterns can support CRM or cross-sell analysis?

Because the sales data is denominated in Turkish lira during a high-inflation period, we supplemented the Kaggle dataset with monthly CPI data from TCMB EVDS.[^evds] This let us compare nominal revenue with inflation-adjusted real revenue instead of relying only on current-price sales totals.

## Citation

Dataset source:

> Cem Erağan (`cemeraan`). [3A Superstore (Market Orders Data-CRM)](https://www.kaggle.com/datasets/cemeraan/3a-superstore). Kaggle.

The Kaggle dataset is the source for the supermarket transaction and reference data used in this project. CPI data used for inflation adjustment is handled separately in the dbt seed `evds_cpi_monthly`.

[^evds]: TCMB EVDS is the Electronic Data Delivery System of the Central Bank of the Republic of Türkiye. It provides access to official economic time series, including CPI data. See the [EVDS portal](https://evds3.tcmb.gov.tr) and [EVDS documentation](https://evds3.tcmb.gov.tr/dokumanlar) for API and usage details.
