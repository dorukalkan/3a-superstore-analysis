{{ config(
    materialized='table'
) }}

with source_data as (
    select * from {{ ref('int_orderdetail_order_product_enriched')}}
),

final_aggregation as (
    select
        branch_region,
        count(distinct item_id) as total_unique_products
    from source_data
    group by branch_region
)

select * from final_aggregation