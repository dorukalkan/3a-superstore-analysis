with endpoint_counts as (

    select
        category1,
        max(case when order_month = date '2021-01-01' then item_count end)
            as base_item_count,
        max(case when order_month = date '2023-06-01' then item_count end)
            as comparison_item_count
    from {{ ref('mart_product_category_price_trend_monthly') }}
    where order_month in (date '2021-01-01', date '2023-06-01')
    group by category1

)

select
    category1,
    base_item_count,
    comparison_item_count
from endpoint_counts
where coalesce(base_item_count, 0) < 5
    or coalesce(comparison_item_count, 0) < 5
