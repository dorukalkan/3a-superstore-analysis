with orderdetail_order as (

    select *
    from {{ ref('int_orderdetail_order_enriched') }}

),

customers as (

    select *
    from {{ ref('stg_raw_customers') }}

),

final as (

    select

        orderdetail_order.order_detail_id,
        orderdetail_order.order_id,
        orderdetail_order.order_date,
        orderdetail_order.order_day_type,
        orderdetail_order.order_year,
        orderdetail_order.order_month,
        orderdetail_order.order_quarter,
        orderdetail_order.order_day_name,
        orderdetail_order.order_year_month,

        orderdetail_order.customer_id,

        customers.full_name,
        customers.gender,
        customers.email,
        customers.region,
        customers.city,
        customers.town,
        customers.district,
        customers.address,
        customers.birth_date,
date_diff(current_date(), birth_date, year)
as customer_age,
        sum(total_price)
over(partition by customer_id)
as customer_lifetime_revenue,
count(distinct order_id)
over(partition by customer_id)
as customer_total_orders,
date_diff(
    current_date(),
    max(order_date)
        over(partition by customer_id),
    day
) as customer_recency_days,
date_diff(
    max(order_date)
        over(partition by customer_id),

    min(order_date)
        over(partition by customer_id),

    day
) as customer_tenure_days,
count(distinct format_date('%Y-%m', order_date))
over(partition by customer_id)
as customer_active_months,


        orderdetail_order.branch_id,
        orderdetail_order.item_id,
        orderdetail_order.item_code,

        orderdetail_order.amount,
        orderdetail_order.unit_price,
        orderdetail_order.total_price,
        orderdetail_order.total_basket

    from orderdetail_order

    left join customers
        on orderdetail_order.customer_id = cast(customers.user_id as int64)

)

select *
from final