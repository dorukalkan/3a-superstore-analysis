select
    metric_key,
    base_value,
    comparison_value,
    absolute_change,
    pct_change,
    index_jan_2021_100
from {{ ref('mart_revenue_story_kpis') }}
where abs(absolute_change - (comparison_value - base_value)) > 0.000001
    or abs(pct_change - (safe_divide(comparison_value, base_value) - 1)) > 0.000001
    or abs(index_jan_2021_100 - safe_divide(comparison_value, base_value) * 100) > 0.000001
