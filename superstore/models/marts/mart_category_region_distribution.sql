{{ config(materialized='table') }}

SELECT

    branch_region,
    branch_city,

    category1,
    category2,

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(DISTINCT item_id) AS unique_products,

    SUM(amount) AS total_quantity,

    SUM(total_price) AS total_revenue,

    AVG(safe_total_basket) AS avg_basket_value

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0

GROUP BY

    branch_region,
    branch_city,

    category1,
    category2