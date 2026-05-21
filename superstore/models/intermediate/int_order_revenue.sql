{{ config(materialized='table') }}

with orders as (

    select *
    from {{ ref('stg_orders') }}

),

order_lines as (

    select
        order_id,
        cast(round(sum(total_price), 2) as numeric) as line_nominal_revenue,
        sum(amount) as units_sold,
        count(*) as line_item_count
    from {{ ref('stg_order_details') }}
    group by order_id

),

order_revenue as (

    select
        orders.order_id,
        orders.branch_id,
        orders.customer_id,
        orders.order_date,
        date_trunc(orders.order_date, month) as order_month,
        extract(year from orders.order_date) as order_year,
        extract(quarter from orders.order_date) as order_quarter,
        orders.total_basket as nominal_order_revenue,
        coalesce(order_lines.line_nominal_revenue, cast(0 as numeric)) as line_nominal_revenue,
        coalesce(order_lines.units_sold, 0) as units_sold,
        coalesce(order_lines.line_item_count, 0) as line_item_count,
        orders.total_basket - coalesce(order_lines.line_nominal_revenue, cast(0 as numeric))
            as revenue_reconciliation_diff,
        abs(orders.total_basket - coalesce(order_lines.line_nominal_revenue, cast(0 as numeric))) > 0.01
            as has_revenue_reconciliation_issue
    from orders
    left join order_lines
        on orders.order_id = order_lines.order_id

)

select *
from order_revenue
