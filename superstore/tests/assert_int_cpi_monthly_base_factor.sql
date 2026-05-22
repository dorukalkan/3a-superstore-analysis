select
    cpi_month,
    inflation_adjustment_factor
from {{ ref('int_cpi_monthly') }}
where cpi_month = date '2023-07-01'
    and inflation_adjustment_factor != 1
