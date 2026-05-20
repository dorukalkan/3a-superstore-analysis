select
    o.order_id,
    o.customer_id,
    o.order_date,

    od.item_id,
    od.amount,
    od.unit_price,
    od.total_price,

    b.city,
    b.region,
    b.branch_town

from {{ ref('stg_orders') }} o

left join {{ ref('stg_order_details') }} od
    on o.order_id = od.order_id

left join {{ ref('stg_branch') }} b
    on o.branch_id = b.branch_id