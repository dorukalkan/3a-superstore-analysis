{{ config(materialized='view') }}

WITH order_details AS (

    SELECT *
    FROM {{ ref('stg_order_details') }}

),

orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

deduplicated_branch AS (

    SELECT *
    FROM (

        SELECT *,

        ROW_NUMBER() OVER(
            PARTITION BY branch_id
            ORDER BY city
        ) AS rn

        FROM {{ ref('stg_branch') }}

    )

    WHERE rn = 1

),

deduplicated_categories AS (

    SELECT *
    FROM (

        SELECT *,

        ROW_NUMBER() OVER(
            PARTITION BY itemid
            ORDER BY category1
        ) AS rn

        FROM {{ ref('stg_raw_categories') }}

    )

    WHERE rn = 1

)

SELECT

    od.order_detail_id,
    od.order_id,

    o.order_date,
    o.branch_id,

    b.region AS branch_region,
    b.city AS branch_city,
    b.town AS branch_town,

    od.item_id,

    c.category1,
    c.category2,
    c.category3,
    c.category4,

    od.amount,
    od.unit_price,
    od.total_price,

    SAFE_CAST(o.total_basket AS NUMERIC) AS safe_total_basket

FROM order_details od

LEFT JOIN orders o
    ON od.order_id = o.order_id

LEFT JOIN deduplicated_branch b
    ON o.branch_id = b.branch_id

LEFT JOIN deduplicated_categories c
    ON od.item_id = c.itemid