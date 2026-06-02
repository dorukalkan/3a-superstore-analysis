{{ config(materialized='table') }}

with endpoint_categories as (

    select *
    from {{ ref('mart_product_category_price_trend_monthly') }}
    where order_month = date '2023-06-01'

)

select
    category1,
    median_effective_paid_price_pct_change_since_jan_2021,
    price_increase_rank
from endpoint_categories
