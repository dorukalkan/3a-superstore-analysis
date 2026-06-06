WITH deduplicated_branches AS (
    SELECT * FROM `superstore-analysis-496710.analytics.stg_branch`
    QUALIFY ROW_NUMBER() OVER(PARTITION BY branch_id ORDER BY branch_id) = 1
)
SELECT 
    o.order_date,
    
    -- Yeni: Hafta İçi / Hafta Sonu Segmenti
    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM o.order_date) IN (1, 7) THEN 'Hafta Sonu' 
        ELSE 'Hafta İçi' 
    END AS is_weekend,
    
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    EXTRACT(MONTH FROM o.order_date) AS order_month,
    FORMAT_DATE('%A', o.order_date) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM o.order_date) AS day_of_week_num,
    
    CASE 
        WHEN EXTRACT(MONTH FROM o.order_date) IN (12, 1, 2) THEN 'Kış'
        WHEN EXTRACT(MONTH FROM o.order_date) IN (3, 4, 5) THEN 'İlkbahar'
        WHEN EXTRACT(MONTH FROM o.order_date) IN (6, 7, 8) THEN 'Yaz'
        WHEN EXTRACT(MONTH FROM o.order_date) IN (9, 10, 11) THEN 'Sonbahar'
    END AS season,
    
    b.region AS branch_region,
    b.city AS branch_city,
    
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_basket) AS total_revenue,
    AVG(o.total_basket) AS avg_basket_value

FROM `superstore-analysis-496710.analytics.stg_orders` o
LEFT JOIN deduplicated_branches b ON o.branch_id = b.branch_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9