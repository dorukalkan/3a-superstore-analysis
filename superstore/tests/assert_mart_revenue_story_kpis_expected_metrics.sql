with expected as (

    select metric_key
    from unnest([
        'nominal_revenue',
        'cpi_index',
        'real_revenue',
        'order_count',
        'units_sold',
        'customer_count'
    ]) as metric_key

),

actual as (

    select metric_key
    from {{ ref('mart_revenue_story_kpis') }}

)

select coalesce(expected.metric_key, actual.metric_key) as metric_key
from expected
full outer join actual
    on expected.metric_key = actual.metric_key
where expected.metric_key is null
    or actual.metric_key is null
