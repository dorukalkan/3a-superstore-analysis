{{ config(materialized='table') }}

with order_revenue as (

    select *
    from {{ ref('int_order_revenue') }}

),

cpi as (

    select *
    from {{ ref('int_cpi_monthly') }}

),

monthly_revenue as (

    select
        order_month,
        extract(year from order_month) as order_year,
        extract(quarter from order_month) as order_quarter,
        count(*) as order_count,
        count(distinct customer_id) as customer_count,
        sum(nominal_order_revenue) as nominal_revenue,
        sum(line_nominal_revenue) as line_nominal_revenue,
        sum(units_sold) as units_sold,
        sum(line_item_count) as line_item_count,
        safe_divide(sum(nominal_order_revenue), count(*)) as nominal_avg_order_value,
        safe_divide(sum(units_sold), count(*)) as units_per_order
    from order_revenue
    group by order_month

),

monthly_revenue_with_cpi as (

    select
        monthly_revenue.order_month,
        monthly_revenue.order_year,
        monthly_revenue.order_quarter,
        monthly_revenue.order_count,
        monthly_revenue.customer_count,
        monthly_revenue.nominal_revenue,
        monthly_revenue.line_nominal_revenue,
        monthly_revenue.units_sold,
        monthly_revenue.line_item_count,
        monthly_revenue.nominal_avg_order_value,
        monthly_revenue.units_per_order,
        monthly_revenue.nominal_revenue * cpi.inflation_adjustment_factor as real_revenue,
        monthly_revenue.line_nominal_revenue * cpi.inflation_adjustment_factor as line_real_revenue,
        monthly_revenue.nominal_avg_order_value * cpi.inflation_adjustment_factor as real_avg_order_value,
        cpi.cpi_index_2003_100,
        cpi.cpi_mom_rate,
        cpi.cpi_yoy_rate,
        cpi.inflation_adjustment_factor,
        cpi.real_revenue_base_month
    from monthly_revenue
    left join cpi
        on monthly_revenue.order_month = cpi.cpi_month

)

select *
from monthly_revenue_with_cpi
