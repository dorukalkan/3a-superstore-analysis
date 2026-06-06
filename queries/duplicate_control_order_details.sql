SELECT order_detail_id,
count(*) as dublicate_count 
FROM `superstore-analysis-496710.dbt_eda.stg_order_details` 
group by order_detail_id having count(*) > 1