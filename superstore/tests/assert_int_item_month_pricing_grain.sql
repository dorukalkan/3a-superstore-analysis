select
    item_id,
    order_month,
    count(*) as row_count
from {{ ref('int_item_month_pricing') }}
group by
    item_id,
    order_month
having count(*) != 1
