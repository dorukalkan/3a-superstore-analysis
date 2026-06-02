{{ config(materialized='table') }}

with line_pricing as (

    select *
    from {{ ref('int_order_line_pricing') }}

),

item_month_pricing as (

    select
        item_id,
        item_code,
        order_month,
        format_date('%Y-%m', order_month) as month_label,
        count(*) as line_count,
        sum(amount) as units_sold,
        avg(effective_paid_unit_price) as avg_effective_paid_unit_price,
        approx_quantiles(effective_paid_unit_price, 101)[offset(50)] as median_effective_paid_unit_price,
        avg(real_effective_paid_unit_price) as avg_real_effective_paid_unit_price,
        approx_quantiles(real_effective_paid_unit_price, 101)[offset(50)] as median_real_effective_paid_unit_price,
        avg(source_unit_price) as avg_source_unit_price,
        approx_quantiles(source_unit_price, 101)[offset(50)] as median_source_unit_price,
        avg(line_price_variance_rate) as avg_line_price_variance_rate,
        approx_quantiles(line_price_variance_rate, 101)[offset(50)] as median_line_price_variance_rate,
        any_value(cpi_index_jan_2021_100) as cpi_index_jan_2021_100,
        any_value(inflation_adjustment_factor) as inflation_adjustment_factor
    from line_pricing
    group by
        item_id,
        item_code,
        order_month,
        month_label

)

select *
from item_month_pricing
