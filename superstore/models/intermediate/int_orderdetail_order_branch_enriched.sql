with sales_orders as (

    select *
    from {{ ref('int_orderdetail_order_enriched') }}

),

branches as (

    select *
    from {{ ref('stg_branch') }}

),

final as (

    select

        -- grain
        sales_orders.order_detail_id,

        -- order info
        sales_orders.order_id,
        sales_orders.order_date,
        sales_orders.order_day_type,
        sales_orders.order_year,
        sales_orders.order_month,
        sales_orders.order_quarter,
        sales_orders.order_day_name,
        sales_orders.order_year_month,
        sum(total_price)over(partition by sales_orders.branch_id)as branch_total_revenue,
        avg(total_basket)over(partition by sales_orders.branch_id)as branch_avg_basket,

        -- branch info
        sales_orders.branch_id,
        branches.branch_town,
        branches.city as branch_city,
        branches.region as branch_region,
        branches.latitude as branch_lat,
        branches.longitude as branch_lon,

        -- product info
        sales_orders.item_id,
        sales_orders.item_code,

        -- metrics
        sales_orders.amount,
        sales_orders.unit_price,
        sales_orders.total_price,
        sales_orders.total_basket

    from sales_orders

    left join branches
        on sales_orders.branch_id = branches.branch_id

)

select *
from final