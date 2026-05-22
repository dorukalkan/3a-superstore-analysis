with cpi as (

    select *
    from {{ ref('int_cpi_monthly') }}

)

select
    cpi.cpi_month,
    cpi.cpi_mom_rate,
    cpi.cpi_yoy_rate
from cpi
left join cpi as prior_month
    on cpi.cpi_month = date_add(prior_month.cpi_month, interval 1 month)
left join cpi as prior_year
    on cpi.cpi_month = date_add(prior_year.cpi_month, interval 1 year)
where
    (prior_month.cpi_month is null and cpi.cpi_mom_rate is not null)
    or (prior_month.cpi_month is not null and cpi.cpi_mom_rate is null)
    or (prior_year.cpi_month is null and cpi.cpi_yoy_rate is not null)
    or (prior_year.cpi_month is not null and cpi.cpi_yoy_rate is null)
