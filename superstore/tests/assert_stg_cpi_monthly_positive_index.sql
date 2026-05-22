select
    cpi_month,
    cpi_index_2003_100
from {{ ref('stg_cpi_monthly') }}
where cpi_index_2003_100 <= 0
