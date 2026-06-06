WITH deduplicated_categories AS (
    SELECT * FROM `superstore-analysis-496710.analytics.stg_raw_categories`
    QUALIFY ROW_NUMBER() OVER(PARTITION BY itemid ORDER BY itemid) = 1
),
-- SADECE EN ÇOK SATAN 20 ÜRÜNÜ BULUYORUZ
top_20_items AS (
    SELECT item_id
    FROM `superstore-analysis-496710.analytics.stg_order_details`
    GROUP BY item_id
    ORDER BY COUNT(DISTINCT order_id) DESC
    LIMIT 20
),
item_base_sales AS (
    SELECT item_id, COUNT(DISTINCT order_id) AS total_orders
    FROM `superstore-analysis-496710.analytics.stg_order_details`
    WHERE item_id IN (SELECT item_id FROM top_20_items)
    GROUP BY item_id
),
paired_items AS (
    SELECT 
        a.item_id AS item_a, 
        b.item_id AS item_b, 
        COUNT(DISTINCT a.order_id) AS times_bought_together,
        SUM(a.total_price + b.total_price) AS combo_revenue
    FROM `superstore-analysis-496710.analytics.stg_order_details` a
    JOIN `superstore-analysis-496710.analytics.stg_order_details` b 
        ON a.order_id = b.order_id AND a.item_id != b.item_id
    -- Sadece Top 20 ürünleri "Temel Ürün (A)" olarak kabul et
    WHERE a.item_id IN (SELECT item_id FROM top_20_items)
    GROUP BY 1, 2
)

SELECT 
    cat_a.itemname AS base_product,
    cat_a.category1 AS base_category,
    
    cat_b.itemname AS cross_sell_product,
    cat_b.category1 AS cross_sell_category,
    
    pi.times_bought_together AS frequency,
    pi.combo_revenue,
    
    ROUND((pi.times_bought_together / ibs.total_orders) * 100, 2) AS confidence_percentage

FROM paired_items pi
JOIN item_base_sales ibs ON pi.item_a = ibs.item_id
LEFT JOIN deduplicated_categories cat_a ON pi.item_a = cat_a.itemid
LEFT JOIN deduplicated_categories cat_b ON pi.item_b = cat_b.itemid
WHERE pi.times_bought_together > 3