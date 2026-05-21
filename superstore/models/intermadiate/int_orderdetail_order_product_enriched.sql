{{ config(materialized='view') }}

SELECT

    -- ORDER INFO
    od.order_detail_id,
    od.order_id,
    o.order_date,
    o.order_datetime,

    -- CUSTOMER
    o.customer_id,
    o.customer_name,

    -- BRANCH
    b.branch_id,
    b.region        AS branch_region,
    b.city          AS branch_city,
    b.town          AS branch_town,
    b.branch_town,
    b.latitude      AS branch_lat,
    b.longitude     AS branch_lon,

    -- PRODUCT
    od.item_id,
    od.item_code,
    c.itemname,
    c.brand,
    c.category1,
    c.category2,
    c.category3,
    c.category4,

    -- SALES METRICS
    od.amount,
    od.unit_price,
    od.total_price,

    -- ORDER METRICS
    o.total_basket AS safe_total_basket,

    -- DATE FEATURES
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    FORMAT_DATE('%Y-%m', o.order_date) AS year_month,
    EXTRACT(QUARTER FROM o.order_date) AS order_quarter,
    EXTRACT(DAYOFWEEK FROM o.order_date) AS day_of_week

FROM {{ ref('stg_order_details') }} od

LEFT JOIN {{ ref('stg_orders') }} o
    ON od.order_id = o.order_id

LEFT JOIN {{ ref('stg_branch') }} b
    ON o.branch_id = b.branch_id

LEFT JOIN {{ ref('stg_raw_categories') }} c
    ON od.item_id = c.itemid