---
icon: lucide/map-pin
title: Region & Category Performance
description: Revenue and category performance analysis
author: Eda Bilgin
---

# Regional Revenue and Category Performance

!!! note "Summary"

    Revenue is not distributed evenly across regions. Marmara is the strongest region, generating about **3.82B TRY**.

    Category mix also shows concentration. The top category is **EV**, which contributes **26.18%** of revenue in the dashboard.

    The business should protect high-performing regions while using regional category differences to plan more localized campaigns, inventory, and growth actions.

![Regional Revenue Overview](../assets/Regional_Revenue_Overview.png)

The dashboard shows where revenue is generated across Türkiye and which product categories drive that revenue. It combines region-level revenue, category contribution, average basket value, and top-category ranking.

## Business Question

This analysis focuses on a regional planning question:

> Where is revenue concentrated, and which categories drive regional performance?

To answer this, the analysis compares branch regions, branch cities, product categories, total revenue, total quantity, order activity, and average basket value.

## What the Evidence Shows

<div class="grid cards" markdown>

-   :lucide-map-pinned:{ .lg .middle } __Top region__

    ---

    Marmara is the leading region, with about **3.82B TRY** in revenue.

-   :lucide-layers:{ .lg .middle } __Category breadth__

    ---

    The dashboard tracks **21** total categories.

-   :lucide-medal:{ .lg .middle } __Top category__

    ---

    `EV` is the top category, contributing **26.18%** of revenue.

-   :lucide-shopping-cart:{ .lg .middle } __Average basket value__

    ---

    Average basket value is **302.08**.

</div>

## Methodology

The regional analysis is built from order lines enriched with order, branch, and product-category information. This lets the dashboard connect sales metrics to both geography and category hierarchy.

The main mart aggregates revenue by branch region, branch city, top-level category, and second-level category. It calculates total orders, unique products, total quantity, total revenue, and average basket value.

??? info "dbt models used"

    - `int_orderdetail_order_product_enriched`: joins order details with orders, customer/order context, branch geography, and product categories.
    - `mart_category_region_distribution`: aggregates regional and category metrics for orders, products, quantity, revenue, and average basket value.
    - `fct_daily_branch_revenue`: supports branch/date revenue analysis with order count, customer count, revenue, units sold, and average order value.

## Evidence Behind the Conclusion

### Marmara is the strongest revenue region

The regional treemap shows Marmara as the largest revenue block. It is followed by other major regions such as İç Anadolu, Ege, Akdeniz, Güneydoğu Anadolu, Karadeniz, and Doğu Anadolu.

This concentration matters because regional performance is not balanced. The business should treat Marmara as a core revenue market, while still investigating whether other regions have growth or coverage gaps.

### Category contribution differs by region

The region/category stacked chart shows how major categories contribute across regions. EV, OYUNCAK, KOZMETIK, GIDA, and BEBEK are visible contributors, but their mix is not identical in every region.

This suggests that regional planning should not use one national category strategy everywhere. Category demand can vary by geography, so campaigns and inventory should be adjusted locally where possible.

### A small group of categories drives a large share of revenue

The category contribution and top-category charts show that EV, OYUNCAK, KOZMETIK, and GIDA are among the most important visible contributors.

EV is the top category at 26.18% of revenue. That makes it important for merchandising and availability, but it also creates dependency risk if the business relies too heavily on a limited number of categories.

## Business Implications

!!! tip "Regional planning takeaway"

    The strongest regions and categories should be protected, but growth planning should also look for regional gaps where category demand is underdeveloped.

Regional revenue concentration is useful because it shows where the business is strongest. But it also points to a planning risk: if a few regions and categories carry too much revenue, local disruption or category weakness can affect overall performance.

## Recommended Actions

- Prioritize inventory availability and campaign execution in Marmara and other high-revenue regions.
- Build region-specific category campaigns instead of applying the same category mix everywhere.
- Investigate weaker regions for demand, distribution, branch coverage, or assortment gaps.
- Track average basket value by region and category to find higher-value regional opportunities.
- Use the top categories to guide merchandising, promotion planning, and category-level revenue monitoring.
