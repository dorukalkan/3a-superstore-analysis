---
icon: lucide/user-search
title: Customer Retention & RFM Analysis
description: Customer retention and RFM analysis
author: Yasemen Dündar
---

# Customer Retention & RFM Analysis

!!! note "Summary"

    RFM segmentation shows where retention work should go first.

    The dashboard identifies **18K** At Risk customers, a **57.9%** Active Customer Rate, and **2.08bn** in Revenue At Risk. Potential Loyalists represent the largest RFM revenue segment, while Medium Value customers contain the largest revenue-at-risk pool.

    The practical takeaway is that retention should be prioritized by behavior and value together, not by customer count alone.

![Power BI Customer Health Dashboard](../assets/Customer_Retention_RFM_Analysis.png)

The dashboard uses RFM segmentation to compare customer recency, frequency, monetary value, segment composition, revenue at risk, and demographic revenue split.

## Business Question

This analysis focuses on a retention prioritization question:

> Which customer groups should be prioritized for retention, and how much revenue is at risk?

To answer this, the analysis compares customer recency, RFM segment, customer value segment, active rate, and revenue at risk.

## What the Evidence Shows

<div class="grid cards" markdown>

-   :lucide-user-x:{ .lg .middle } __At Risk customers__

    ---

    The dashboard identifies **18K** customers in the At Risk group.

-   :lucide-activity:{ .lg .middle } __Active customer rate__

    ---

    The active customer rate is **57.9%**.

-   :lucide-badge-alert:{ .lg .middle } __Revenue at risk__

    ---

    At Risk customers represent approximately **2.08bn** in revenue at risk.

-   :lucide-user-check:{ .lg .middle } __Potential Loyalists lead revenue__

    ---

    Potential Loyalists represent **5.78bn**, or **44.11%**, of RFM revenue share.

</div>

## Methodology

RFM stands for Recency, Frequency, and Monetary value. The analysis scores customers based on how recently they purchased, how often they purchased, and how much revenue they generated.

The RFM model is built on top of the customer 360 mart. Each customer receives quintile scores for recency, frequency, and monetary value. These scores are combined into an RFM score and translated into business-facing segments:

| Segment | Meaning |
| --- | --- |
| Champions | Highly engaged, high-value customers. |
| Loyal Customers | Customers with consistent purchasing behavior. |
| Potential Loyalist | Customers with meaningful value or engagement who can be moved upward. |
| At Risk | Customers showing weaker engagement and higher retention risk. |

??? info "dbt models used"

    - `mart_customer_360`: customer-level base table with lifetime revenue, order count, recency, tenure, active months, average order value, value segment, and lifecycle stage.
    - `mart_customer_rfm`: adds recency, frequency, and monetary quintile scores, a combined RFM score, total score, and RFM segment label.

## Evidence Behind the Conclusion

### Recency is connected to value concentration

The recency scatter plot shows customer lifetime value against days since last order. Recent customers contain stronger value concentration, while customers further away from their last order tend to sit lower.

This does not mean recency is the only driver of value, but it makes recency an important retention signal. Customers who were valuable but have not ordered recently deserve attention before their revenue becomes harder to recover.

### Potential Loyalists are the largest RFM revenue segment

The RFM segment composition chart shows Potential Loyalists as the largest revenue segment, with 5.78bn and 44.11% of RFM revenue share.

That makes this segment a major growth opportunity. Moving even a portion of Potential Loyalists into Loyal Customer or Champion behavior can have a meaningful revenue impact.

### Medium Value customers carry the largest revenue-at-risk block

The revenue-at-risk chart shows that Medium Value customers account for the largest risk block at about 1.33bn. Low Value customers follow at about 0.54bn, High Value customers at about 0.21bn, and VIP customers at about 0.01bn.

This suggests retention should not focus only on the highest-value label. Medium Value customers have enough revenue scale that churn prevention in this group can produce a larger total impact.

### Gender does not appear to be the main segmentation driver

The revenue share by RFM segment and gender chart is relatively balanced across segments.

This means retention strategy should primarily use behavioral segmentation, such as recency, frequency, monetary value, and value segment. Gender may still be useful as secondary context, but it is not the main driver shown in this dashboard.

## Business Implications

!!! tip "Retention takeaway"

    Not all retention work has the same expected return. The strongest targets are customers who combine meaningful value with signs of weakening engagement.

At Risk customers represent immediate revenue protection. Potential Loyalists represent growth potential. Medium Value At Risk customers deserve special attention because they combine risk with scale.

## Recommended Actions

- Re-engage At Risk customers through targeted campaigns before inactivity becomes permanent.
- Prioritize Medium Value customers within the At Risk group because they contain the largest revenue-at-risk pool.
- Move Potential Loyalists toward Loyal Customer behavior with repeat-purchase and loyalty campaigns.
- Protect Champions with personalized retention, recognition, or high-value loyalty treatment.
- Use behavioral segmentation first, and treat demographic splits as secondary context.
- Add predictive churn modeling over time using recency, frequency, monetary value, category behavior, and purchase timing.
