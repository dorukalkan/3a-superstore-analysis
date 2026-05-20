with 

source as (

    select * from {{ source('raw', 'categories') }}

),

renamed as (

    select
        itemid,
        category1,
        category1_id,
        category2,
        category2_id,
        category3,
        category3_id,
        category4,
        category4_id,
        brand,
        itemcode,
        itemname

    from source

)

select * from renamed