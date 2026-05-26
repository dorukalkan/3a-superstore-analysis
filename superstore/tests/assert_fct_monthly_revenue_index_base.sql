select
    order_month,
    nominal_revenue_index_jan_2021_100,
    real_revenue_index_jan_2021_100
from {{ ref('fct_monthly_revenue') }}
where order_month = date '2021-01-01'
    and (
        abs(nominal_revenue_index_jan_2021_100 - 100) > 0.000001
        or abs(real_revenue_index_jan_2021_100 - 100) > 0.000001
    )
