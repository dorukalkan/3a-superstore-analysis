---
icon: lucide/shopping-basket
title: Category Trends
description: Category performance & trends
author: Eda Bilgin
---

# Category Performance & Trends

!!! note "Summary"

    Category performance appears to be driven more by order activity and quantity sold than by major shifts in category mix.

    `EV` is the leading visible category by revenue and sales volume, while the overall category composition remains relatively stable over time.

    This suggests that the business can plan around stable customer category preferences, while still monitoring dependency on dominant categories.

![Category Performance Trends](../assets/Category_Performance_Trends.png)

The dashboard focuses on category-level demand. It compares category revenue, sales quantity, order count, and category composition over time.

## Business Question

This analysis focuses on a category planning question:

> Which categories drive revenue, and are customer category preferences changing over time?

To answer this, the analysis compares revenue by category, quantity sold, order activity by month, and category composition over time.

## What the Evidence Shows

<div class="grid cards" markdown>

-   :lucide-chart-scatter:{ .lg .middle } __Revenue follows volume__

    ---

    Higher-volume categories generally generate higher revenue in the category bubble chart.

-   :lucide-home:{ .lg .middle } __EV is the leading visible category__

    ---

    `EV` stands out as the largest visible category by revenue and quantity.

-   :lucide-activity:{ .lg .middle } __Orders and quantity move together__

    ---

    Monthly total quantity and total order count follow a similar pattern.

-   :lucide-layout-dashboard:{ .lg .middle } __Category mix is stable__

    ---

    Category contribution remains relatively steady across the visible months.

</div>

## Methodology

The category trend analysis uses order-line data enriched with product category information. The main focus is demand behavior: revenue, quantity sold, order activity, and contribution by category.

This page is about category demand and category mix. It is separate from the inflation-adjusted product price analysis, which looks at realized paid price changes and CPI-adjusted pricing.

??? info "dbt models used"

    - `int_orderdetail_order_product_enriched`: combines order details with order dates, branch geography, product names, brands, and category hierarchy.
    - `mart_category_region_distribution`: aggregates category and regional metrics such as total orders, unique products, total quantity, total revenue, and average basket value.
    - Product category price marts are used in the separate inflation analysis when the question is price movement rather than category demand.

## Evidence Behind the Conclusion

### Higher-volume categories generate more revenue

The revenue vs. sales volume bubble chart shows a clear positive relationship between quantity sold and revenue. Categories with higher sales volume tend to generate higher revenue.

This indicates that category performance is strongly connected to demand and sales activity, not only to category presence.

### Order count and quantity move together

The monthly chart shows total quantity sold and total order count moving in a similar direction across months.

This suggests that changes in category performance are closely tied to customer purchasing activity. When order activity rises or falls, quantity sold tends to move with it.

### Category composition remains stable

The stacked category composition chart shows that major category shares remain relatively stable over the visible period.

That means the business did not experience a major category mix shift in this view. Revenue movement appears to be more about overall sales activity and quantity sold than customers suddenly moving from one category group to another.

## Business Implications

!!! tip "Category planning takeaway"

    Stable category preferences make planning easier, but dominant categories still need close monitoring because they carry a large share of revenue and demand.

If category mix is stable, the business can plan inventory, promotions, and staffing around known demand patterns. At the same time, dominant categories such as EV should be monitored for dependency risk, stock availability, and promotion effectiveness.

## Recommended Actions

- Maintain strong availability for high-volume, high-revenue categories.
- Use category demand patterns to guide inventory planning and merchandising.
- Watch lower-performing categories for assortment, pricing, or promotion opportunities.
- Monitor whether campaigns or seasonal events change category composition over time.
- Pair this demand analysis with the inflation-adjusted product price analysis when evaluating category profitability.
