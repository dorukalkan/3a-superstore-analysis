{{ config(materialized='table') }}

with branch_coverage as (

    select *
    from {{ ref('stg_branch') }}

),

branch_dim as (

    select
        branch_id,
        any_value(region) as region,
        any_value(city) as city,
        any_value(branch_town) as branch_town,
        count(distinct town) as covered_town_count
    from branch_coverage
    group by branch_id

)

select *
from branch_dim
