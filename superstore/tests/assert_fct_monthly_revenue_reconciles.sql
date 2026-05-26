with expected as (

    select
        order_month,
        count(*) as order_count,
        sum(nominal_order_revenue) as nominal_revenue
    from {{ ref('int_order_revenue') }}
    group by order_month

),

actual as (

    select
        order_month,
        order_count,
        nominal_revenue
    from {{ ref('fct_monthly_revenue') }}

)

select
    coalesce(expected.order_month, actual.order_month) as order_month,
    expected.order_count as expected_order_count,
    actual.order_count as actual_order_count,
    expected.nominal_revenue as expected_nominal_revenue,
    actual.nominal_revenue as actual_nominal_revenue
from expected
full outer join actual
    on expected.order_month = actual.order_month
where
    coalesce(expected.order_count, -1) != coalesce(actual.order_count, -1)
    or abs(coalesce(expected.nominal_revenue, 0) - coalesce(actual.nominal_revenue, 0)) > 0.01
