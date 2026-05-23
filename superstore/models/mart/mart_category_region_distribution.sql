{{ config(materialized='table') }}

SELECT

    branch_region,
    branch_city,

    category1,
    category2,

    item_id,

    EXTRACT(MONTH FROM order_date) AS month_no,
    FORMAT_DATE('%b', order_date) AS month_name,

    COUNT(DISTINCT order_id) AS total_orders,

    SUM(amount) AS total_quantity,

    SUM(total_price) AS total_revenue,

    AVG(safe_total_basket) AS avg_basket_value

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0

GROUP BY

    branch_region,
    branch_city,

    category1,
    category2,

    item_id,

    month_no,
    month_name