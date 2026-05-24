-- Fix: DATE(created_at) uses UTC; orders after 22:00 UTC (midnight Madrid) fall on wrong date.
-- Solution: use AT TIME ZONE 'Europe/Madrid' for all date calculations in dashboard views.

CREATE OR REPLACE VIEW view_sales_weekly_revenue AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as order_date,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid')
ORDER BY order_date ASC;

CREATE OR REPLACE VIEW view_sales_by_establishment AS
SELECT
    e.id as establishment_id,
    e.name as establishment_name,
    e.address,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM establishments e
LEFT JOIN orders o ON e.id = o.establishment_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY e.id, e.name, e.address, DATE(o.created_at AT TIME ZONE 'Europe/Madrid');

CREATE OR REPLACE VIEW view_sales_by_category AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    r.category as category_name,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), r.category;

CREATE OR REPLACE VIEW view_sales_top_dishes AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    oi.name as dish_name,
    r.category as category_name,
    mci.price as price,
    SUM(oi.quantity) as qty_sold,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), oi.name, r.category, mci.price
ORDER BY revenue DESC;

CREATE OR REPLACE VIEW view_sales_ticket_distribution AS
WITH order_totals AS (
    SELECT
        o.id as order_id,
        o.establishment_id,
        DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
        COALESCE(SUM(oi.quantity * mci.price), 0) as total
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
    GROUP BY o.id, o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid')
)
SELECT
    establishment_id,
    date,
    CASE
        WHEN total < 20 THEN '< 20€'
        WHEN total >= 20 AND total <= 50 THEN '20€ - 50€'
        WHEN total > 50 AND total <= 100 THEN '50€ - 100€'
        ELSE '> 100€'
    END as range,
    COUNT(*) as tickets
FROM order_totals
GROUP BY establishment_id, date, range;

CREATE OR REPLACE VIEW view_orders_hourly AS
SELECT
    establishment_id,
    DATE(created_at AT TIME ZONE 'Europe/Madrid') as date,
    EXTRACT(HOUR FROM (created_at AT TIME ZONE 'Europe/Madrid')) as hour_of_day,
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'served') as served_orders,
    COUNT(*) FILTER (WHERE status IN ('pending', 'confirmed', 'preparing')) as active_orders
FROM orders
GROUP BY establishment_id, DATE(created_at AT TIME ZONE 'Europe/Madrid'), EXTRACT(HOUR FROM (created_at AT TIME ZONE 'Europe/Madrid'))
ORDER BY date ASC, hour_of_day ASC;

CREATE OR REPLACE VIEW view_orders_room_performance AS
SELECT
    rm.establishment_id,
    rm.id as room_id,
    rm.name as room_name,
    rm.floor,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    COUNT(DISTINCT t.id) as total_tables,
    COUNT(DISTINCT o.id) as total_orders
FROM rooms rm
LEFT JOIN tables t ON rm.id = t.room_id
LEFT JOIN orders o ON rm.id = o.room_id
GROUP BY rm.establishment_id, rm.id, rm.name, rm.floor, DATE(o.created_at AT TIME ZONE 'Europe/Madrid');

CREATE OR REPLACE VIEW view_orders_pipeline AS
SELECT
    establishment_id,
    DATE(created_at AT TIME ZONE 'Europe/Madrid') as date,
    status as stage,
    COUNT(*) as count
FROM orders
GROUP BY establishment_id, DATE(created_at AT TIME ZONE 'Europe/Madrid'), status;

CREATE OR REPLACE VIEW view_orders_feed AS
SELECT
    o.id,
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    to_char(o.created_at AT TIME ZONE 'Europe/Madrid', 'HH24:MI') as time,
    t.table_number as table_name,
    o.status,
    (SELECT string_agg(quantity || 'x ' || name, ', ')
     FROM order_items oi WHERE oi.order_id = o.id) as summary
FROM orders o
LEFT JOIN tables t ON o.table_id = t.id
ORDER BY o.created_at DESC;

CREATE OR REPLACE VIEW view_orders_top_cancellations AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    oi.name as dish,
    COUNT(*) as quantity,
    'Cancelado' as reason
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE oi.status = 'cancelled' OR o.status = 'cancelled'
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), oi.name;

CREATE OR REPLACE VIEW view_tables_status AS
SELECT
    rm.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    t.id as table_id,
    t.table_number,
    t.capacity,
    rm.name as room_name,
    CASE
        WHEN o.id IS NOT NULL THEN 'occupied'
        ELSE 'free'
    END as status,
    u.name as waiter_name,
    o.created_at as occupied_since,
    (SELECT SUM(quantity) FROM order_items WHERE order_id = o.id) as diners
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
LEFT JOIN users u ON o.waiter_id = u.id;

CREATE OR REPLACE VIEW view_tables_size_distribution AS
SELECT
    rm.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    t.capacity,
    COUNT(t.id) as total_tables,
    COUNT(o.id) as occupied_tables
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
GROUP BY rm.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), t.capacity
ORDER BY t.capacity ASC;

CREATE OR REPLACE VIEW view_staff_performance AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    u.id as user_id,
    u.name as waiter_name,
    COUNT(DISTINCT o.id) as orders_served,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue_generated
FROM users u
LEFT JOIN orders o ON u.id = o.waiter_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
WHERE u.role = 'waiter'
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), u.id, u.name;

CREATE OR REPLACE VIEW view_staff_zones AS
SELECT
    r.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    wz.id,
    wz.user_id,
    u.name as waiter_name,
    wz.room_id,
    r.name as room_name,
    COUNT(DISTINCT t.id) as tables_assigned,
    COUNT(DISTINCT o.id) as active_tables,
    CASE
        WHEN COUNT(DISTINCT o.id) >= 5 THEN 'busy'
        WHEN COUNT(DISTINCT o.id) > 0 THEN 'normal'
        ELSE 'unassigned'
    END as status
FROM waiter_zones wz
JOIN users u ON wz.user_id = u.id
JOIN rooms r ON wz.room_id = r.id
LEFT JOIN tables t ON r.id = t.room_id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
GROUP BY r.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), wz.id, wz.user_id, u.name, wz.room_id, r.name;

CREATE OR REPLACE VIEW view_staff_activity_log AS
SELECT
    o.establishment_id,
    DATE(osh.changed_at AT TIME ZONE 'Europe/Madrid') as date,
    osh.id,
    osh.changed_at as time,
    u.name as user_name,
    'Cambió pedido a ' || osh.new_status as action,
    CASE WHEN osh.new_status = 'cancelled' THEN 'warning' ELSE 'info' END as type
FROM order_status_history osh
JOIN orders o ON osh.order_id = o.id
LEFT JOIN users u ON o.waiter_id = u.id
WHERE osh.new_status IN ('cancelled', 'served')
UNION ALL
SELECT
    o.establishment_id,
    DATE(aa.created_at AT TIME ZONE 'Europe/Madrid') as date,
    aa.id,
    aa.created_at as time,
    u.name as user_name,
    'Alerta: ' || aa.message as action,
    'alert' as type
FROM allergen_alerts aa
LEFT JOIN order_items oi ON aa.order_item_id = oi.id
LEFT JOIN orders o ON oi.order_id = o.id
LEFT JOIN users u ON aa.resolved_by = u.id
ORDER BY time DESC LIMIT 200;

CREATE OR REPLACE VIEW view_allergens_frequency AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    a.eu_number,
    a.code,
    a.name_es,
    COUNT(aa.id) as comensals_count
FROM allergens a
JOIN allergen_alerts aa ON a.id = aa.allergen_id
JOIN order_items oi ON aa.order_item_id = oi.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), a.id, a.eu_number, a.code, a.name_es;

CREATE OR REPLACE VIEW view_allergens_heatmap AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    r.id as recipe_id,
    r.name as dish_name,
    jsonb_object_agg(a.code, CASE WHEN ra.contains THEN 'C' ELSE 'T' END) as allergens
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN recipes r ON mci.recipe_id = r.id
JOIN recipe_allergens ra ON r.id = ra.recipe_id
JOIN allergens a ON ra.allergen_id = a.id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), r.id, r.name;

CREATE OR REPLACE VIEW view_allergens_presence AS
SELECT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    CASE WHEN ra.contains THEN 'Contiene' ELSE 'Trazas' END as label,
    COUNT(*) as value
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN recipes r ON mci.recipe_id = r.id
JOIN recipe_allergens ra ON r.id = ra.recipe_id
GROUP BY o.establishment_id, DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), ra.contains;

CREATE OR REPLACE VIEW view_allergens_alternatives AS
SELECT DISTINCT
    o.establishment_id,
    DATE(o.created_at AT TIME ZONE 'Europe/Madrid') as date,
    r1.name as original,
    (SELECT array_agg(a.name_es) FROM recipe_allergens ra JOIN allergens a ON ra.allergen_id = a.id WHERE ra.recipe_id = r1.id) as original_allergens,
    r2.name as replacement,
    ralt.reason
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN recipes r1 ON mci.recipe_id = r1.id
JOIN recipe_alternatives ralt ON r1.id = ralt.recipe_id
JOIN recipes r2 ON ralt.alternative_recipe_id = r2.id;

CREATE OR REPLACE VIEW view_allergens_alerts_recent AS
SELECT
    o.establishment_id,
    DATE(aa.created_at AT TIME ZONE 'Europe/Madrid') as date,
    aa.id,
    to_char(aa.created_at AT TIME ZONE 'Europe/Madrid', 'HH24:MI') as time,
    c.name as comensal,
    al.name_es as allergen,
    oi.name as dish,
    'Mesa ' || t.table_number as table,
    aa.alert_severity as severity,
    aa.is_resolved as resolved,
    u.name as waiter
FROM allergen_alerts aa
LEFT JOIN comensals c ON aa.comensal_id = c.id
LEFT JOIN allergens al ON aa.allergen_id = al.id
LEFT JOIN order_items oi ON aa.order_item_id = oi.id
LEFT JOIN orders o ON oi.order_id = o.id
LEFT JOIN tables t ON o.table_id = t.id
LEFT JOIN users u ON aa.resolved_by = u.id
ORDER BY aa.created_at DESC;

GRANT SELECT ON view_sales_weekly_revenue TO web_anon;
GRANT SELECT ON view_sales_by_establishment TO web_anon;
GRANT SELECT ON view_sales_by_category TO web_anon;
GRANT SELECT ON view_sales_top_dishes TO web_anon;
GRANT SELECT ON view_sales_ticket_distribution TO web_anon;
GRANT SELECT ON view_orders_hourly TO web_anon;
GRANT SELECT ON view_orders_room_performance TO web_anon;
GRANT SELECT ON view_orders_pipeline TO web_anon;
GRANT SELECT ON view_orders_feed TO web_anon;
GRANT SELECT ON view_orders_top_cancellations TO web_anon;
GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_tables_size_distribution TO web_anon;
GRANT SELECT ON view_staff_performance TO web_anon;
GRANT SELECT ON view_staff_zones TO web_anon;
GRANT SELECT ON view_staff_activity_log TO web_anon;
GRANT SELECT ON view_allergens_frequency TO web_anon;
GRANT SELECT ON view_allergens_heatmap TO web_anon;
GRANT SELECT ON view_allergens_presence TO web_anon;
GRANT SELECT ON view_allergens_alternatives TO web_anon;
GRANT SELECT ON view_allergens_alerts_recent TO web_anon;
