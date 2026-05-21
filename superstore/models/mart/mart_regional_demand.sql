{{ config(materialized='table') }}

SELECT

    branch_region,
    branch_city,
    branch_town,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(amount) AS total_quantity_sold,

    SUM(total_price) AS total_revenue,

    AVG(total_price) AS avg_order_revenue

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0

GROUP BY
    branch_region,
    branch_city,
    branch_town