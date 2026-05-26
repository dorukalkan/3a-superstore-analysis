select
    order_month
from {{ ref('mart_revenue_trend_monthly') }}
where order_month < date '2021-01-01'
    or order_month > date '2023-06-01'

union all

select
    expected_month as order_month
from unnest(generate_date_array(date '2021-01-01', date '2023-06-01', interval 1 month)) as expected_month
left join {{ ref('mart_revenue_trend_monthly') }} as trend
    on expected_month = trend.order_month
where trend.order_month is null
