select
    category1,
    median_effective_paid_price_index_jan_2021_100,
    median_real_effective_paid_price_index_jan_2021_100
from {{ ref('mart_product_category_price_trend_monthly') }}
where order_month = date '2021-01-01'
    and (
        abs(median_effective_paid_price_index_jan_2021_100 - 100) > 0.000001
        or abs(median_real_effective_paid_price_index_jan_2021_100 - 100) > 0.000001
    )
