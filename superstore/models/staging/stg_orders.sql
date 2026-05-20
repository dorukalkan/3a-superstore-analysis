with source as (

    select
        *
    from {{ source('raw', 'orders') }}

),

cleaned as (

    select
        -- ids
        cast(ORDERID as int64) as order_id,
        cast(BRANCH_ID as string) as branch_id,
        cast(USERID as int64) as customer_id,

        -- dates
        cast(DATE as datetime) as order_datetime,
        date(DATE) as order_date,

        -- customer names
        cast(NAMESURNAME as string) as customer_name,

        -- monetary values
        safe_cast(
            replace(TOTALBASKET, ',', '.') as numeric
        ) as total_basket

    from source

)

select
    *
from cleaned