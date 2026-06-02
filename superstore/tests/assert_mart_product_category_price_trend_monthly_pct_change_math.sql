select
    order_month,
    category1,
    median_effective_paid_price_index_jan_2021_100,
    median_effective_paid_price_pct_change_since_jan_2021
from {{ ref('mart_product_category_price_trend_monthly') }}
where abs(
    median_effective_paid_price_pct_change_since_jan_2021
    - (safe_divide(median_effective_paid_price_index_jan_2021_100, 100) - 1)
) > 0.000001
