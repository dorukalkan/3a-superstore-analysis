with 

source as (

    select * from {{ source('raw', 'customers') }}

),


parsed as (

    select

        split(string_field_0, ';')[offset(0)] as user_id,
        split(string_field_0, ';')[offset(1)] as email,
        split(string_field_0, ';')[offset(2)] as full_name,
        split(string_field_0, ';')[offset(3)] as status,
        split(string_field_0, ';')[offset(4)] as gender,
        split(string_field_0, ';')[offset(5)] as birth_date,
        split(string_field_0, ';')[offset(6)] as region,
        split(string_field_0, ';')[offset(7)] as city,
        split(string_field_0, ';')[offset(8)] as town,
        split(string_field_0, ';')[offset(9)] as district,
        split(string_field_0, ';')[offset(10)] as address

    from source

)

select *
from parsed