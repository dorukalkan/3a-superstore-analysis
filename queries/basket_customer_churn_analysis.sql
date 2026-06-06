WITH deduplicated_categories AS (
    SELECT * FROM `superstore-analysis-496710.analytics.stg_raw_categories`
    QUALIFY ROW_NUMBER() OVER(PARTITION BY itemid ORDER BY itemid) = 1
),
unique_customers AS (
    SELECT * FROM `superstore-analysis-496710.analytics.stg_raw_customers`
    QUALIFY ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY user_id) = 1
),
-- CHURN MOTORU: Müşterinin son alışverişi üzerinden kaç gün geçmiş?
customer_churn AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        -- Veritabanındaki en son alışveriş tarihini baz alıp gün farkını buluyoruz
        DATE_DIFF((SELECT MAX(order_date) FROM `superstore-analysis-496710.analytics.stg_orders`), MAX(order_date), DAY) AS days_idle
    FROM `superstore-analysis-496710.analytics.stg_orders`
    GROUP BY customer_id
),
order_insights AS (
    SELECT 
        od.order_id,
        COUNT(od.item_id) AS total_items_qty,
        COUNT(DISTINCT cat.category1) AS unique_category_count
    FROM `superstore-analysis-496710.analytics.stg_order_details` od
    LEFT JOIN deduplicated_categories cat ON od.item_id = cat.itemid
    GROUP BY od.order_id
)

SELECT 
    o.order_id,
    o.order_date,
    
    -- Müşteri Bilgileri ve Churn
    c.full_name AS customer_name,
    CASE 
        WHEN ch.days_idle > 90 THEN 'Churn (Kayıp)' 
        ELSE 'Aktif' 
    END AS churn_status,
    ch.days_idle AS days_since_last_order,
    
    -- Sepet Bilgileri
    o.total_basket AS basket_revenue,
    oi.total_items_qty,
    oi.unique_category_count,
    
    CASE 
        WHEN oi.unique_category_count = 1 THEN '1. Tek Kategori'
        WHEN oi.unique_category_count = 2 THEN '2. Çift Kategori'
        WHEN oi.unique_category_count >= 3 THEN '3. Çoklu Kategori (Çapraz Satış)'
        ELSE 'Bilinmiyor'
    END AS basket_diversity_segment

FROM `superstore-analysis-496710.analytics.stg_orders` o
JOIN order_insights oi ON o.order_id = oi.order_id
LEFT JOIN unique_customers c ON CAST(o.customer_id AS STRING) = c.user_id
LEFT JOIN customer_churn ch ON o.customer_id = ch.customer_id