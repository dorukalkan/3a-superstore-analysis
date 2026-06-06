SELECT 
branch_id,
town,
count(*) as dublicate_count
FROM `superstore-analysis-496710.dbt_eda.stg_branch`
group by branch_id, town

having count(*)>1 