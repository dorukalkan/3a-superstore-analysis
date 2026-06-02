select
    order_month,
    category1,
    count(*) as row_count
from {{ ref('mart_product_category_price_trend_monthly') }}
group by
    order_month,
    category1
having count(*) != 1
