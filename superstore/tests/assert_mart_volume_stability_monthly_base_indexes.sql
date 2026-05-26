select
    metric_key,
    index_jan_2021_100,
    index_point_change_vs_base,
    pct_change_vs_base
from {{ ref('mart_volume_stability_monthly') }}
where order_month = date '2021-01-01'
    and (
        abs(index_jan_2021_100 - 100) > 0.000001
        or abs(index_point_change_vs_base) > 0.000001
        or abs(pct_change_vs_base) > 0.000001
    )
