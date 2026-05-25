{{ config(materialized='table') }}

with cpi as (

    select *
    from {{ ref('stg_cpi_monthly') }}

),

indexed as (

    select
        cpi.*,
        max(
            case
                when cpi_month = date '2021-01-01'
                then cpi_index_2003_100
            end
        ) over () as base_cpi_index_2003_100
    from cpi

),

cpi_metrics as (

    select
        indexed.cpi_month,
        indexed.cpi_index_2003_100,
        indexed.source_series_code,
        safe_divide(
            indexed.cpi_index_2003_100,
            prior_month.cpi_index_2003_100
        ) - 1 as cpi_mom_rate,
        safe_divide(
            indexed.cpi_index_2003_100,
            prior_year.cpi_index_2003_100
        ) - 1 as cpi_yoy_rate,
        date '2021-01-01' as real_revenue_base_month,
        indexed.base_cpi_index_2003_100,
        safe_divide(
            indexed.base_cpi_index_2003_100,
            indexed.cpi_index_2003_100
        ) as inflation_adjustment_factor
    from indexed
    left join cpi as prior_month
        on indexed.cpi_month = date_add(prior_month.cpi_month, interval 1 month)
    left join cpi as prior_year
        on indexed.cpi_month = date_add(prior_year.cpi_month, interval 1 year)

)

select *
from cpi_metrics
