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

        orderdetail_order.branch_id,
        orderdetail_order.item_id,
        orderdetail_order.item_code,

        orderdetail_order.amount,
        orderdetail_order.unit_price,
        orderdetail_order.total_price,
        orderdetail_order.safe_total_basket

    from orderdetail_order

    left join customers
        on orderdetail_order.customer_id = cast(customers.user_id as int64)

)

select *
from final