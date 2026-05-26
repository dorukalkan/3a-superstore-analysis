select
    order_month,
    nominal_revenue,
    real_revenue,
    inflation_adjustment_factor
from {{ ref('fct_monthly_revenue') }}
where abs(real_revenue - nominal_revenue * inflation_adjustment_factor) > 0.01
