{{ config(materialized='table') }}

with monthly_revenue as (

    select *
    from {{ ref('fct_monthly_revenue') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

),

indexed as (

    select
        order_month,
        format_date('%Y-%m', order_month) as month_label,
        cast(order_count as numeric) as order_count,
        cast(units_sold as numeric) as units_sold,
        cast(customer_count as numeric) as customer_count,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(order_count as numeric)
            end
        ) over () as base_order_count,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(units_sold as numeric)
            end
        ) over () as base_units_sold,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(customer_count as numeric)
            end
        ) over () as base_customer_count
    from monthly_revenue

),

volume_metrics as (

    select
        order_month,
        month_label,
        'order_count' as metric_key,
        order_count as actual_value,
        safe_divide(order_count, base_order_count) * 100 as index_jan_2021_100
    from indexed

    union all

    select
        order_month,
        month_label,
        'units_sold' as metric_key,
        units_sold as actual_value,
        safe_divide(units_sold, base_units_sold) * 100 as index_jan_2021_100
    from indexed

    union all

    select
        order_month,
        month_label,
        'customer_count' as metric_key,
        customer_count as actual_value,
        safe_divide(customer_count, base_customer_count) * 100 as index_jan_2021_100
    from indexed

)

select
    order_month,
    month_label,
    metric_key,
    actual_value,
    index_jan_2021_100,
    index_jan_2021_100 - 100 as index_point_change_vs_base,
    safe_divide(index_jan_2021_100, 100) - 1 as pct_change_vs_base
from volume_metrics
