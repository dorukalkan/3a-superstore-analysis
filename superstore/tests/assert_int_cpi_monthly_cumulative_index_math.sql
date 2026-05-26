select
    cpi_month,
    inflation_adjustment_factor,
    cpi_index_jan_2021_100
from {{ ref('int_cpi_monthly') }}
where abs(cpi_index_jan_2021_100 - safe_divide(100, inflation_adjustment_factor)) > 0.000001
