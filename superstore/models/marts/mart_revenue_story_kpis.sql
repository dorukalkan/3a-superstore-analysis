{{ config(materialized='table') }}

with monthly_revenue as (

    select *
    from {{ ref('fct_monthly_revenue') }}
    where order_month in (date '2021-01-01', date '2023-06-01')

),

comparison_values as (

    select
        date '2021-01-01' as base_month,
        date '2023-06-01' as comparison_month,
        max(
            case
                when order_month = date '2021-01-01'
                then nominal_revenue
            end
        ) as base_nominal_revenue,
        max(
            case
                when order_month = date '2023-06-01'
                then nominal_revenue
            end
        ) as comparison_nominal_revenue,
        max(
            case
                when order_month = date '2021-01-01'
                then real_revenue
            end
        ) as base_real_revenue,
        max(
            case
                when order_month = date '2023-06-01'
                then real_revenue
            end
        ) as comparison_real_revenue,
        max(
            case
                when order_month = date '2021-01-01'
                then cpi_index_jan_2021_100
            end
        ) as base_cpi_index,
        max(
            case
                when order_month = date '2023-06-01'
                then cpi_index_jan_2021_100
            end
        ) as comparison_cpi_index,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(order_count as numeric)
            end
        ) as base_order_count,
        max(
            case
                when order_month = date '2023-06-01'
                then cast(order_count as numeric)
            end
        ) as comparison_order_count,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(units_sold as numeric)
            end
        ) as base_units_sold,
        max(
            case
                when order_month = date '2023-06-01'
                then cast(units_sold as numeric)
            end
        ) as comparison_units_sold,
        max(
            case
                when order_month = date '2021-01-01'
                then cast(customer_count as numeric)
            end
        ) as base_customer_count,
        max(
            case
                when order_month = date '2023-06-01'
                then cast(customer_count as numeric)
            end
        ) as comparison_customer_count
    from monthly_revenue

),

kpis as (

    select
        'nominal_revenue' as metric_key,
        base_month,
        comparison_month,
        base_nominal_revenue as base_value,
        comparison_nominal_revenue as comparison_value
    from comparison_values

    union all

    select
        'cpi_index',
        base_month,
        comparison_month,
        base_cpi_index,
        comparison_cpi_index
    from comparison_values

    union all

    select
        'real_revenue',
        base_month,
        comparison_month,
        base_real_revenue,
        comparison_real_revenue
    from comparison_values

    union all

    select
        'order_count',
        base_month,
        comparison_month,
        base_order_count,
        comparison_order_count
    from comparison_values

    union all

    select
        'units_sold',
        base_month,
        comparison_month,
        base_units_sold,
        comparison_units_sold
    from comparison_values

    union all

    select
        'customer_count',
        base_month,
        comparison_month,
        base_customer_count,
        comparison_customer_count
    from comparison_values

)

select
    metric_key,
    base_month,
    comparison_month,
    base_value,
    comparison_value,
    comparison_value - base_value as absolute_change,
    safe_divide(comparison_value, base_value) - 1 as pct_change,
    safe_divide(comparison_value, base_value) * 100 as index_jan_2021_100
from kpis
