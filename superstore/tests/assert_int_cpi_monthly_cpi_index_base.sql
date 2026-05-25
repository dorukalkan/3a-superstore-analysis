select
    cpi_month,
    cpi_index_jan_2021_100
from {{ ref('int_cpi_monthly') }}
where cpi_month = date '2021-01-01'
    and abs(cpi_index_jan_2021_100 - 100) > 0.000001
