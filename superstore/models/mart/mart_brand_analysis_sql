{{ config(materialized='table') }}

SELECT

    brand,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(amount) AS total_quantity_sold,

    SUM(total_price) AS total_revenue,

    AVG(unit_price) AS avg_unit_price

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0
AND brand IS NOT NULL

GROUP BY
    brand