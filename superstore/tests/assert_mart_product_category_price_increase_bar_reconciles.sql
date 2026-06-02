with expected as (

    select
        category1,
        median_effective_paid_price_pct_change_since_jan_2021,
        price_increase_rank
    from {{ ref('mart_product_category_price_trend_monthly') }}
    where order_month = date '2023-06-01'

),

actual as (

    select
        category1,
        median_effective_paid_price_pct_change_since_jan_2021,
        price_increase_rank
    from {{ ref('mart_product_category_price_increase_bar') }}

)

select
    coalesce(expected.category1, actual.category1) as category1,
    expected.median_effective_paid_price_pct_change_since_jan_2021
        as expected_price_pct_change,
    actual.median_effective_paid_price_pct_change_since_jan_2021
        as actual_price_pct_change,
    expected.price_increase_rank as expected_price_increase_rank,
    actual.price_increase_rank as actual_price_increase_rank
from expected
full outer join actual
    on expected.category1 = actual.category1
where expected.category1 is null
    or actual.category1 is null
    or abs(
        expected.median_effective_paid_price_pct_change_since_jan_2021
        - actual.median_effective_paid_price_pct_change_since_jan_2021
    ) > 0.000001
    or expected.price_increase_rank != actual.price_increase_rank
