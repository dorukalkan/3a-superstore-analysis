with source as (
    select * from {{ source('raw', 'order_details') }}
),
cleaned as (
select
    ORDERID as order_id,
    ORDERDETAILID as order_detail_id,
    ITEMID as item_id,
    ITEMCODE as item_code,

    cast(AMOUNT as int64) as amount,

    SAFE_CAST(REPLACE(UNITPRICE, ',', '.') AS FLOAT64) as unit_price,

    SAFE_CAST(REPLACE(TOTALPRICE, ',', '.') AS FLOAT64) as total_price

from source
)
select * from cleaned