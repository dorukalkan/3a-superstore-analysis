{{ config(materialized='table') }}

with branch_coverage as (

    select *
    from {{ ref('stg_branch') }}

),

branch_dim as (

    select
        branch_id,
        min(region) as region,
        min(city) as city,
        min(branch_town) as branch_town,
        count(distinct town) as covered_town_count
    from branch_coverage
    group by branch_id

)

select *
from branch_dim
