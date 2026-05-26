{{ config(materialized='table') }}

with monthly_trend as (

    select *
    from {{ ref('mart_product_price_trend_monthly') }}
    where order_month in (date '2021-01-01', date '2023-06-01')

),

item_month as (

    select *
    from {{ ref('int_item_month_pricing') }}
    where order_month in (date '2021-01-01', date '2023-06-01')

),

trend_comparison as (

    select
        date '2021-01-01' as base_month,
        date '2023-06-01' as comparison_month,
        max(
            case
                when order_month = date '2021-01-01'
                then median_effective_paid_unit_price
            end
        ) as base_median_effective_paid_unit_price,
        max(
            case
                when order_month = date '2023-06-01'
                then median_effective_paid_unit_price
            end
        ) as comparison_median_effective_paid_unit_price,
        max(
            case
                when order_month = date '2021-01-01'
                then median_real_effective_paid_unit_price
            end
        ) as base_median_real_effective_paid_unit_price,
        max(
            case
                when order_month = date '2023-06-01'
                then median_real_effective_paid_unit_price
            end
        ) as comparison_median_real_effective_paid_unit_price,
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
        ) as comparison_cpi_index
    from monthly_trend

),

item_comparison as (

    select
        item_id,
        max(
            case
                when order_month = date '2021-01-01'
                then median_effective_paid_unit_price
            end
        ) as base_item_median_effective_paid_unit_price,
        max(
            case
                when order_month = date '2023-06-01'
                then median_effective_paid_unit_price
            end
        ) as comparison_item_median_effective_paid_unit_price,
        max(
            case
                when order_month = date '2021-01-01'
                then line_count
            end
        ) as base_item_line_count,
        max(
            case
                when order_month = date '2023-06-01'
                then line_count
            end
        ) as comparison_item_line_count
    from item_month
    group by item_id

),

eligible_items as (

    select *
    from item_comparison
    where base_item_median_effective_paid_unit_price is not null
        and comparison_item_median_effective_paid_unit_price is not null
        and base_item_line_count >= 5
        and comparison_item_line_count >= 5

),

item_kpis as (

    select
        count(*) as eligible_item_count,
        countif(
            comparison_item_median_effective_paid_unit_price
            > base_item_median_effective_paid_unit_price
        ) as items_with_increased_effective_paid_price,
        countif(
            comparison_item_median_effective_paid_unit_price
            = base_item_median_effective_paid_unit_price
        ) as items_with_unchanged_effective_paid_price,
        countif(
            comparison_item_median_effective_paid_unit_price
            < base_item_median_effective_paid_unit_price
        ) as items_with_decreased_effective_paid_price,
        avg(
            safe_divide(
                comparison_item_median_effective_paid_unit_price,
                base_item_median_effective_paid_unit_price
            ) - 1
        ) as avg_item_effective_paid_price_pct_change,
        approx_quantiles(
            safe_divide(
                comparison_item_median_effective_paid_unit_price,
                base_item_median_effective_paid_unit_price
            ) - 1,
            101
        )[offset(50)] as median_item_effective_paid_price_pct_change
    from eligible_items

)

select
    trend_comparison.base_month,
    trend_comparison.comparison_month,
    trend_comparison.base_median_effective_paid_unit_price,
    trend_comparison.comparison_median_effective_paid_unit_price,
    trend_comparison.comparison_median_effective_paid_unit_price
        - trend_comparison.base_median_effective_paid_unit_price
        as median_effective_paid_unit_price_absolute_change,
    safe_divide(
        trend_comparison.comparison_median_effective_paid_unit_price,
        trend_comparison.base_median_effective_paid_unit_price
    ) - 1 as median_effective_paid_unit_price_pct_change,
    safe_divide(
        trend_comparison.comparison_median_effective_paid_unit_price,
        trend_comparison.base_median_effective_paid_unit_price
    ) * 100 as median_effective_paid_unit_price_index_jan_2021_100,
    trend_comparison.base_median_real_effective_paid_unit_price,
    trend_comparison.comparison_median_real_effective_paid_unit_price,
    safe_divide(
        trend_comparison.comparison_median_real_effective_paid_unit_price,
        trend_comparison.base_median_real_effective_paid_unit_price
    ) - 1 as median_real_effective_paid_unit_price_pct_change,
    safe_divide(
        trend_comparison.comparison_cpi_index,
        trend_comparison.base_cpi_index
    ) - 1 as cpi_pct_change,
    item_kpis.eligible_item_count,
    item_kpis.items_with_increased_effective_paid_price,
    item_kpis.items_with_unchanged_effective_paid_price,
    item_kpis.items_with_decreased_effective_paid_price,
    safe_divide(
        item_kpis.items_with_increased_effective_paid_price,
        item_kpis.eligible_item_count
    ) as items_with_increased_effective_paid_price_pct,
    item_kpis.avg_item_effective_paid_price_pct_change,
    item_kpis.median_item_effective_paid_price_pct_change
from trend_comparison
cross join item_kpis
