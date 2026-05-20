with source as (
    select * from {{ source('raw', 'branch') }}
),
cleaned as (
select

    BRANCH_ID as branch_id,
    REGION as region,
    CITY as city,
    initcap(TOWN) as town,
    initcap(BRANCH_TOWN) as branch_town,

    round(cast(LAT as numeric) / 100000000,6) as latitude,
    round(cast(LON as numeric) / 100000000,6) as longitude

from source
)
select * from cleaned 