{{ config(materialized='table') }}

SELECT

    branch_region,

    COUNT(DISTINCT category2) AS category_diversity

FROM {{ ref('int_orderdetail_order_product_enriched') }}

WHERE total_price > 0

GROUP BY branch_region