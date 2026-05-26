with source as (

    select *
    from {{ ref('evds_cpi_monthly') }}

),

cleaned as (

    select
        date_trunc(cast(cpi_month as date), month) as cpi_month,
        cast(cpi_index_2003_100 as numeric) as cpi_index_2003_100,
        cast(source_series_code as string) as source_series_code
    from source

)

select *
from cleaned
