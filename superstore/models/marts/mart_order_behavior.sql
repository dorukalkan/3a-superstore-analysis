select

    order_id,

    max(order_date) as order_date,
    max(order_year) as order_year,
    max(order_month) as order_month,
    max(order_day_type) as order_day_type,

    max(branch_id) as branch_id,
    max(customer_id) as customer_id,

    -- order metrics
    max(order_total_quantity)
        as order_total_quantity,

    max(order_item_count)
        as order_item_count,

    max(total_basket)
        as total_basket,

    sum(total_price)
        as order_revenue

from {{ ref('int_orderdetail_order_enriched') }}

group by order_id