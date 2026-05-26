with expected as (

    select
        order_month,
        'order_count' as metric_key,
        cast(order_count as numeric) as actual_value
    from {{ ref('fct_monthly_revenue') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

    union all

    select
        order_month,
        'units_sold' as metric_key,
        cast(units_sold as numeric) as actual_value
    from {{ ref('fct_monthly_revenue') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

    union all

    select
        order_month,
        'customer_count' as metric_key,
        cast(customer_count as numeric) as actual_value
    from {{ ref('fct_monthly_revenue') }}
    where order_month between date '2021-01-01' and date '2023-06-01'

),

actual as (

    select
        order_month,
        metric_key,
        actual_value
    from {{ ref('mart_volume_stability_monthly') }}

)

select
    expected.order_month,
    expected.metric_key,
    expected.actual_value as expected_actual_value,
    actual.actual_value as actual_actual_value
from expected
left join actual
    on expected.order_month = actual.order_month
    and expected.metric_key = actual.metric_key
where abs(expected.actual_value - actual.actual_value) > 0.000001
    or actual.actual_value is null
