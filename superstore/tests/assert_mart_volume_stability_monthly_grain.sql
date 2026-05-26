select
    order_month,
    metric_key,
    count(*) as row_count
from {{ ref('mart_volume_stability_monthly') }}
group by order_month, metric_key
having count(*) != 1
