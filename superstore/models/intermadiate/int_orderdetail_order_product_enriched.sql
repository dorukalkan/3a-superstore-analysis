{{ config(materialized='view') }}

SELECT

    -- ORDER DETAIL
    od.order_detail_id,
    od.order_id,

    -- ORDER INFO
    o.order_date,
    

    -- CUSTOMER
    o.customer_id,
    o.customer_name,

    -- BRANCH
    b.branch_id,
    b.region       AS branch_region,
    b.city         AS branch_city,
    b.town         AS branch_town,
    b.latitude     AS branch_lat,
    b.longitude    AS branch_lon,

    -- PRODUCT
    od.item_id,
    od.item_code,
    c.itemname,
    c.brand,
    c.category1,
    c.category2,
    c.category3,
    c.category4,

    -- SALES
    od.amount,
    od.unit_price,
    od.total_price,
    o.total_basket as safe_total_basket

FROM {{ ref('stg_order_details') }} od

LEFT JOIN {{ ref('stg_orders') }} o
    ON od.order_id = o.order_id

LEFT JOIN {{ ref('stg_branch') }} b
    ON o.branch_id = b.branch_id

LEFT JOIN {{ ref('stg_raw_categories') }} c
    ON od.item_id = c.itemid