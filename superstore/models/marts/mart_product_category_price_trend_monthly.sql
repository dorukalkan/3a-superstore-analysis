{{ config(materialized='table') }}

with item_month_pricing as (

    select *
    from {{ ref('int_item_month_pricing') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

),

categories as (

    select
        itemid as item_id,
        category1
    from {{ ref('stg_raw_categories') }}

),

item_month_with_category as (

    select
        item_month_pricing.*,
        categories.category1
    from item_month_pricing
    inner join categories
        on item_month_pricing.item_id = categories.item_id

),

endpoint_category_item_counts as (

    select
        category1,
        count(distinct case when order_month = date '2021-01-01' then item_id end)
            as base_item_count,
        count(distinct case when order_month = date '2023-06-01' then item_id end)
            as comparison_item_count
    from item_month_with_category
    where order_month in (date '2021-01-01', date '2023-06-01')
    group by category1

),

eligible_categories as (

    select category1
    from endpoint_category_item_counts
    where base_item_count >= 5
        and comparison_item_count >= 5

),

category_month_prices as (

    select
        item_month_with_category.order_month,
        item_month_with_category.month_label,
        item_month_with_category.category1,
        count(distinct item_month_with_category.item_id) as item_count,
        sum(item_month_with_category.line_count) as line_count,
        sum(item_month_with_category.units_sold) as units_sold,
        approx_quantiles(
            item_month_with_category.median_effective_paid_unit_price,
            101
        )[offset(50)] as median_effective_paid_unit_price,
        approx_quantiles(
            item_month_with_category.median_real_effective_paid_unit_price,
            101
        )[offset(50)] as median_real_effective_paid_unit_price,
        any_value(item_month_with_category.cpi_index_jan_2021_100)
            as cpi_index_jan_2021_100
    from item_month_with_category
    inner join eligible_categories
        on item_month_with_category.category1 = eligible_categories.category1
    group by
        item_month_with_category.order_month,
        item_month_with_category.month_label,
        item_month_with_category.category1

),

indexed as (

    select
        category_month_prices.*,
        safe_divide(
            median_effective_paid_unit_price,
            max(
                case
                    when order_month = date '2021-01-01'
                    then median_effective_paid_unit_price
                end
            ) over (partition by category1)
        ) * 100 as median_effective_paid_price_index_jan_2021_100,
        safe_divide(
            median_real_effective_paid_unit_price,
            max(
                case
                    when order_month = date '2021-01-01'
                    then median_real_effective_paid_unit_price
                end
            ) over (partition by category1)
        ) * 100 as median_real_effective_paid_price_index_jan_2021_100
    from category_month_prices

),

with_price_change as (

    select
        indexed.*,
        safe_divide(
            median_effective_paid_price_index_jan_2021_100,
            100
        ) - 1 as median_effective_paid_price_pct_change_since_jan_2021
    from indexed

)

select
    *,
    rank() over (
        partition by order_month
        order by median_effective_paid_price_pct_change_since_jan_2021 desc
    ) as price_increase_rank
from with_price_change
