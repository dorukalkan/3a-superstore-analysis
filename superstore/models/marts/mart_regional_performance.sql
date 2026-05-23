select

    region,

    count(distinct customer_id)
        as total_customers,

    count(distinct order_id)
        as total_orders,

    sum(total_price)
        as regional_revenue,

    avg(total_basket)
        as avg_order_value,

    avg(customer_lifetime_revenue)
        as avg_customer_clv,

    avg(customer_recency_days)
        as avg_recency_days,

    safe_divide(

        count(distinct case
            when customer_total_orders > 1
            then customer_id
        end),

        count(distinct customer_id)

    ) as repeat_customer_rate

from {{ ref('int_orderdetail_order_customer_enriched') }}

group by region