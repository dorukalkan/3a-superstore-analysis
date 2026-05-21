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
        sales_orders.safe_total_basket

    from sales_orders

    left join branches
        on sales_orders.branch_id = branches.branch_id

)

select *
from final