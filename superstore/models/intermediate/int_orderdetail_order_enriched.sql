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
        sum(order_details.amount)over(partition by order_details.order_id)as order_total_quantity,
        count(*) over(partition by order_details.order_id) as order_item_count,
        safe_divide(order_details.total_price,sum(order_details.total_price)over(partition by order_details.order_id)) as order_revenue_share,

        extract(year from orders.order_date) as order_year,
        extract(month from orders.order_date) as order_month,
        extract(quarter from orders.order_date) as order_quarter,
        format_date('%A', order_date) as order_day_name,
        format_date('%Y-%m', order_date) as order_year_month,
            case
            when extract(dayofweek from orders.order_date) in (1,7)
            then 'Weekend'
            else 'Weekday'
        end as order_day_type,

        -- order columns
        orders.branch_id,
        orders.customer_id,
        orders.order_date,
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