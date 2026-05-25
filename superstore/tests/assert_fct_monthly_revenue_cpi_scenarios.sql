select
    order_month,
    nominal_revenue,
    real_revenue,
    inflation_adjustment_factor
from {{ ref('fct_monthly_revenue') }}
where
    (
        order_month = date '2021-01-01'
        and abs(real_revenue - nominal_revenue) > 0.01
    )
    or (
        order_month = date '2023-07-01'
        and inflation_adjustment_factor >= 1
    )
