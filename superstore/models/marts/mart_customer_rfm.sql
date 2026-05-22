with base as (

    select *

    from {{ ref('mart_customer_360') }}

),

rfm as (

    select

        *,

ntile(5)
over(order by customer_recency_days desc)
as r_score,

ntile(5)
over(order by customer_total_orders asc)
as f_score,

ntile(5)
over(order by customer_lifetime_revenue asc)
as m_score

    from base

)

select

    *,

concat(

    'R', cast(r_score as string),
    '-F', cast(f_score as string),
    '-M', cast(m_score as string)

) as rfm_score,

    case

        when r_score >= 4
         and f_score >= 4
         and m_score >= 4

        then 'Champions'

        when r_score >= 3
         and f_score >= 3

        then 'Loyal Customers'

        when r_score <= 2
         and f_score <= 2

        then 'At Risk'

        else 'Potential Loyalist'

    end as rfm_segment,

    r_score + f_score + m_score
as rfm_total_score

from rfm