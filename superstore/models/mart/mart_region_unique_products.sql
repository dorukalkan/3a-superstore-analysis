{{ config(materialized='table') }}

SELECT
    branch_region,

    COUNT(DISTINCT item_id) AS unique_products

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0

GROUP BY branch_region