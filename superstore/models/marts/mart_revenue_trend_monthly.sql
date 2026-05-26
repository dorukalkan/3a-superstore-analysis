{{ config(materialized='table') }}

with monthly_revenue as (

    select *
    from {{ ref('fct_monthly_revenue') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

)

select
    order_month,
    format_date('%Y-%m', order_month) as month_label,
    nominal_revenue,
    real_revenue,
    nominal_revenue_index_jan_2021_100,
    real_revenue_index_jan_2021_100,
    cpi_index_jan_2021_100
from monthly_revenue
