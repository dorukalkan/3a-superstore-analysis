with expected as (

    select
        expected_month as order_month,
        metric_key
    from unnest(generate_date_array(date '2021-01-01', date '2023-06-01', interval 1 month)) as expected_month
    cross join unnest([
        'order_count',
        'units_sold',
        'customer_count'
    ]) as metric_key

),

actual as (

    select
        order_month,
        metric_key
    from {{ ref('mart_volume_stability_monthly') }}

)

select
    coalesce(expected.order_month, actual.order_month) as order_month,
    coalesce(expected.metric_key, actual.metric_key) as metric_key
from expected
full outer join actual
    on expected.order_month = actual.order_month
    and expected.metric_key = actual.metric_key
where expected.order_month is null
    or actual.order_month is null
