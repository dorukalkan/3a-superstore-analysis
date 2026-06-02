select
    base_month,
    comparison_month
from {{ ref('mart_product_price_story_kpis') }}
where base_month != date '2021-01-01'
    or comparison_month != date '2023-06-01'
