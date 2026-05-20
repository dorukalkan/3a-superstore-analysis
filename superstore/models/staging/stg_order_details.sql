select
    ORDERID as order_id,
    ORDERDETAILID as order_detail_id,
    ITEMID as item_id,
    ITEMCODE as item_code,

    cast(AMOUNT as int64) as amount,
    cast(UNITPRICE as numeric) as unit_price,
    cast(TOTALPRICE as numeric) as total_price

from {{ source('raw', 'order_details') }}