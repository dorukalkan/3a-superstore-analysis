{{ config(materialized='table') }}

with order_details as (

    select *
    from {{ ref('stg_order_details') }}
    where amount > 0
        and unit_price > 0
        and total_price > 0

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

cpi as (

    select *
    from {{ ref('int_cpi_monthly') }}

),

line_pricing as (

    select
        order_details.order_detail_id,
        order_details.order_id,
        order_details.item_id,
        order_details.item_code,
        orders.order_date,
        date_trunc(orders.order_date, month) as order_month,
        order_details.amount,
        cast(order_details.unit_price as numeric) as source_unit_price,
        cast(order_details.total_price as numeric) as paid_line_amount,
        cast(order_details.unit_price * order_details.amount as numeric) as gross_line_amount,
        safe_divide(
            cast(order_details.total_price as numeric),
            cast(order_details.amount as numeric)
        ) as effective_paid_unit_price,
        safe_divide(
            cast(order_details.total_price as numeric),
            cast(order_details.amount as numeric)
        ) * cpi.inflation_adjustment_factor as real_effective_paid_unit_price,
        cast(order_details.unit_price * order_details.amount as numeric)
            - cast(order_details.total_price as numeric) as line_price_variance_amount,
        safe_divide(
            cast(order_details.unit_price * order_details.amount as numeric)
                - cast(order_details.total_price as numeric),
            cast(order_details.unit_price * order_details.amount as numeric)
        ) as line_price_variance_rate,
        cpi.cpi_index_jan_2021_100,
        cpi.inflation_adjustment_factor,
        cpi.real_revenue_base_month
    from order_details
    inner join orders
        on order_details.order_id = orders.order_id
    inner join cpi
        on date_trunc(orders.order_date, month) = cpi.cpi_month

)

select *
from line_pricing
