with order_details as (

    select *
    from {{ ref('stg_order_details') }}

),

orders as (

    select *
    from {{ ref('stg_orders') }}

),

final as (

    select

        -- grain
        order_details.order_detail_id,

        -- order detail columns
        order_details.order_id,
        order_details.item_id,
        order_details.item_code,
        order_details.amount,
        order_details.unit_price,
        order_details.total_price,

        -- order columns
        orders.branch_id,
        orders.customer_id,
        orders.order_date,
        orders.customer_name,
        case
        when row_number() over(
            partition by order_details.order_id
            order by order_details.order_detail_id
        ) = 1

        then orders.total_basket
        else 0
    end as safe_total_basket

    from order_details

    left join orders
        on order_details.order_id = orders.order_id

)

select *
from final