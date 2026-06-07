---
icon: lucide/shield-plus
title: Customer Health
description: Customer churn risk
author: Yasemen Dündar
---

# Customer Health

!!! note "Summary"

    Customer value is concentrated geographically and by value segment.

    The top seven cities generate **42.57%** of total revenue, and Medium Value customers generate the largest share of revenue. That makes Medium Value customers the most important group to monitor for near-term retention and upsell opportunities.

    Customer health also improves as customer value increases: VIP customers have the highest Active rate, while Low Value customers show the highest At Risk share.

![Power BI Customer Health Dashboard](../assets/Customer_Health.png)

The dashboard combines customer value, geography, lifecycle stage, and revenue concentration. It helps identify where customer value is generated and which customer groups need attention before revenue is lost.

## Business Question

This analysis focuses on a customer portfolio question:

> Where is customer value concentrated, and which customer groups need retention attention?

To answer this, the analysis looks at customer lifetime revenue, value segments, lifecycle stages, city-level revenue concentration, and health distribution by value segment.

## What the Evidence Shows

<div class="grid cards" markdown>

-   :lucide-users:{ .lg .middle } __Large customer base__

    ---

    The dashboard tracks approximately **99.996K** customers.

-   :lucide-gem:{ .lg .middle } __High average customer value__

    ---

    Average customer lifetime revenue is around **131K**, with average order value around **1.28K**.

-   :lucide-map-pin:{ .lg .middle } __Revenue is geographically concentrated__

    ---

    The top seven cities generate **42.57%** of total revenue.

-   :lucide-shield-alert:{ .lg .middle } __Health varies by value segment__

    ---

    VIP customers have the strongest Active rate, while Low Value customers have the highest At Risk share.

</div>

## Methodology

The customer health analysis is built from a customer-level mart that summarizes each customer's purchase history and lifecycle state.

The model calculates customer lifetime revenue, total order count, tenure, recency, active months, average order value, average basket quantity, repeat-customer flags, value segment, and lifecycle stage.

Value segments are based on customer lifetime revenue:

- Low Value
- Medium Value
- High Value
- VIP

Lifecycle stages are based on recency from the latest order date in the dataset:

| Stage | Meaning |
| --- | --- |
| Active | Customers with very recent purchasing activity. |
| Warm | Customers whose activity has slowed but has not yet become high risk. |
| At Risk | Customers with the longest time since their last order. |

??? info "dbt model used"

    - `mart_customer_360`: one row per customer with lifetime revenue, total orders, tenure, recency, active months, average order value, basket quantity, repeat/high-value flags, value segment, and lifecycle stage.
    - `int_orderdetail_order_customer_enriched`: enriches order lines with customer profile fields and customer-level order behavior before the customer mart is aggregated.

## Evidence Behind the Conclusion

### Customer value is concentrated in major cities

The geographic view shows revenue concentration across Türkiye. İstanbul leads the city table with the largest share, followed by Ankara, İzmir, Bursa, Antalya, Konya, and Adana.

Together, the top seven cities generate 42.57% of total revenue. This concentration is useful for targeting regional campaigns, but it also means the business should monitor dependency on a limited set of high-performing cities.

### Medium Value customers carry the largest revenue share

The revenue distribution treemap shows that Medium Value customers generate the largest revenue block, with the dashboard note highlighting that they generate about 55% of total revenue.

That makes Medium Value customers especially important. They are large enough to move total revenue, and they are often the best near-term target for retention and upgrade campaigns.

### Customer health improves with value

The health distribution table shows a clear pattern across value segments. Active rate rises from Low Value to VIP, while At Risk share falls as customer value increases.

Low Value customers show the highest At Risk share. VIP customers show the strongest Active rate. Medium Value customers sit in the middle, but because they generate the largest revenue share, even moderate health deterioration in this group can matter.

## Business Implications

!!! tip "Retention takeaway"

    The highest-impact retention work is not only about the riskiest customers. It is about the riskiest customers inside the segments that carry meaningful revenue.

Medium Value customers deserve close monitoring because they combine scale with upgrade potential. VIP customers are healthier, but they still need protection because their individual value is high. Lower-value customers may need lower-cost, automated engagement rather than expensive one-to-one retention work.

## Recommended Actions

- Monitor Medium Value customers for movement from Active to Warm or At Risk.
- Launch targeted retention campaigns for At Risk customers, especially when they belong to revenue-heavy segments.
- Create upgrade paths that move Medium Value customers toward High Value and VIP behavior.
- Protect VIP customers with personalized loyalty and service actions.
- Develop regional growth strategies outside the top revenue-generating cities.
- Add predictive churn monitoring over time so customer health can be detected before customers become At Risk.
