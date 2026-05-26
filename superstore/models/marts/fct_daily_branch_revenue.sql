{{ config(materialized='table') }}

with order_revenue as (

    select *
    from {{ ref('int_order_revenue') }}

),

branches as (

    select *
    from {{ ref('int_branch_dim') }}

),

daily_branch_revenue as (

    select
        concat(
            cast(order_revenue.order_date as string),
            '|',
            order_revenue.branch_id
        ) as daily_branch_revenue_key,
        order_revenue.order_date,
        order_revenue.order_month,
        order_revenue.order_year,
        order_revenue.order_quarter,
        order_revenue.branch_id,
        branches.region,
        branches.city,
        branches.branch_town,
        branches.covered_town_count,
        count(*) as order_count,
        count(distinct order_revenue.customer_id) as customer_count,
        sum(order_revenue.nominal_order_revenue) as nominal_revenue,
        sum(order_revenue.line_nominal_revenue) as line_nominal_revenue,
        sum(order_revenue.units_sold) as units_sold,
        sum(order_revenue.line_item_count) as line_item_count,
        safe_divide(sum(order_revenue.nominal_order_revenue), count(*)) as avg_order_value,
        safe_divide(sum(order_revenue.units_sold), count(*)) as units_per_order
    from order_revenue
    left join branches
        on order_revenue.branch_id = branches.branch_id
    group by
        daily_branch_revenue_key,
        order_revenue.order_date,
        order_revenue.order_month,
        order_revenue.order_year,
        order_revenue.order_quarter,
        order_revenue.branch_id,
        branches.region,
        branches.city,
        branches.branch_town,
        branches.covered_town_count

)

select *
from daily_branch_revenue
