{{ config(materialized='table') }}

with line_pricing as (

    select *
    from {{ ref('int_order_line_pricing') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

),

monthly_prices as (

    select
        order_month,
        format_date('%Y-%m', order_month) as month_label,
        count(*) as line_count,
        count(distinct item_id) as item_count,
        sum(amount) as units_sold,
        avg(effective_paid_unit_price) as avg_effective_paid_unit_price,
        approx_quantiles(effective_paid_unit_price, 101)[offset(50)] as median_effective_paid_unit_price,
        avg(real_effective_paid_unit_price) as avg_real_effective_paid_unit_price,
        approx_quantiles(real_effective_paid_unit_price, 101)[offset(50)] as median_real_effective_paid_unit_price,
        avg(source_unit_price) as avg_source_unit_price,
        approx_quantiles(source_unit_price, 101)[offset(50)] as median_source_unit_price,
        avg(line_price_variance_rate) as avg_line_price_variance_rate,
        approx_quantiles(line_price_variance_rate, 101)[offset(50)] as median_line_price_variance_rate,
        any_value(cpi_index_jan_2021_100) as cpi_index_jan_2021_100
    from line_pricing
    group by
        order_month,
        month_label

),

indexed as (

    select
        monthly_prices.*,
        safe_divide(
            median_effective_paid_unit_price,
            max(
                case
                    when order_month = date '2021-01-01'
                    then median_effective_paid_unit_price
                end
            ) over ()
        ) * 100 as median_effective_paid_price_index_jan_2021_100,
        safe_divide(
            median_real_effective_paid_unit_price,
            max(
                case
                    when order_month = date '2021-01-01'
                    then median_real_effective_paid_unit_price
                end
            ) over ()
        ) * 100 as median_real_effective_paid_price_index_jan_2021_100,
        safe_divide(
            median_source_unit_price,
            max(
                case
                    when order_month = date '2021-01-01'
                    then median_source_unit_price
                end
            ) over ()
        ) * 100 as median_source_unit_price_index_jan_2021_100
    from monthly_prices

)

select *
from indexed
