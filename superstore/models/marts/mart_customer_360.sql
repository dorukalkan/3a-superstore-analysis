with customer_orders as (

    select

        customer_id,
        order_id,

        max(full_name) as full_name,
        max(gender) as gender,
        max(region) as region,
        max(city) as city,
        max(customer_age) as customer_age,

        max(order_date) as order_date,

        max(total_basket) as total_basket,

        sum(amount) as order_total_quantity

    from {{ ref('int_orderdetail_order_customer_enriched') }}

    group by customer_id, order_id

),

dataset_max_date as (

    select
        max(order_date) as max_order_date
    from customer_orders

),

final as (

    select

        customer_id,

        max(full_name) as full_name,
        max(gender) as gender,
        max(region) as region,
        max(city) as city,
        max(customer_age) as customer_age,

        -- core metrics

        sum(total_basket)
            as customer_lifetime_revenue,

        count(distinct order_id)
            as customer_total_orders,

        date_diff(

            max(order_date),

            min(order_date),

            day

        ) as customer_tenure_days,

        date_diff(

            dataset_max_date.max_order_date,

            max(order_date),

            day

        ) as customer_recency_days,

        count(distinct format_date('%Y-%m', order_date))
            as customer_active_months,

        -- calculated metrics

        safe_divide(

            sum(total_basket),

            count(distinct order_id)

        ) as customer_avg_order_value,

        avg(order_total_quantity)
            as customer_avg_basket_quantity,

        -- business flags

        case
            when count(distinct order_id) > 1
            then 1
            else 0
        end as is_repeat_customer,

        case
            when sum(total_basket) >= 10000
            then 1
            else 0
        end as is_high_value_customer,

        case

            when sum(total_basket) >= 180000
            then 'VIP'

            when sum(total_basket) >= 140000
            then 'High Value'

            when sum(total_basket) >= 110000
            then 'Medium Value'

            else 'Low Value'

        end as customer_value_segment,

        case

            when date_diff(
                dataset_max_date.max_order_date,
                max(order_date),
                day
            ) <= 7

            then 'Active'

            when date_diff(
                dataset_max_date.max_order_date,
                max(order_date),
                day
            ) <= 15

            then 'Warm'

            else 'At Risk'

        end as customer_lifecycle_stage

    from customer_orders

    cross join dataset_max_date

    group by
        customer_id,
        dataset_max_date.max_order_date

)

select *
from final
