DROP VIEW IF EXISTS view_sales_weekly_revenue;
DROP VIEW IF EXISTS view_sales_by_establishment;
DROP VIEW IF EXISTS view_sales_by_category;
DROP VIEW IF EXISTS view_sales_top_dishes;
DROP VIEW IF EXISTS view_orders_hourly;
DROP VIEW IF EXISTS view_orders_room_performance;
DROP VIEW IF EXISTS view_tables_status;
DROP VIEW IF EXISTS view_tables_size_distribution;
DROP VIEW IF EXISTS view_staff_performance;
DROP VIEW IF EXISTS view_staff_zones;
DROP VIEW IF EXISTS view_staff_activity_log;
DROP VIEW IF EXISTS view_allergens_frequency;
DROP VIEW IF EXISTS view_allergens_alerts_recent;

-- ============================================================================
-- Migration 000018 — Add filters (establishment_id, date) to Dashboard Views
-- ============================================================================

-- ============================================================================
-- 1. SALES (Ventas)
-- ============================================================================

CREATE OR REPLACE VIEW view_sales_weekly_revenue AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as order_date,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY o.establishment_id, DATE(o.created_at)
ORDER BY order_date ASC;

CREATE OR REPLACE VIEW view_sales_by_establishment AS
SELECT 
    e.id as establishment_id,
    e.name as establishment_name,
    e.address,
    DATE(o.created_at) as date,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM establishments e
LEFT JOIN orders o ON e.id = o.establishment_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY e.id, e.name, e.address, DATE(o.created_at);

CREATE OR REPLACE VIEW view_sales_by_category AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    r.category as category_name,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at), r.category;

CREATE OR REPLACE VIEW view_sales_top_dishes AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    oi.name as dish_name,
    r.category as category_name,
    mci.price as price,
    SUM(oi.quantity) as qty_sold,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at), oi.name, r.category, mci.price
ORDER BY revenue DESC;

-- ============================================================================
-- 2. ORDERS (Pedidos)
-- ============================================================================

CREATE OR REPLACE VIEW view_orders_hourly AS
SELECT 
    establishment_id,
    DATE(created_at) as date,
    EXTRACT(HOUR FROM created_at) as hour_of_day,
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'served') as served_orders,
    COUNT(*) FILTER (WHERE status IN ('pending', 'confirmed', 'preparing')) as active_orders
FROM orders
GROUP BY establishment_id, DATE(created_at), EXTRACT(HOUR FROM created_at)
ORDER BY date ASC, hour_of_day ASC;

CREATE OR REPLACE VIEW view_orders_room_performance AS
SELECT 
    rm.establishment_id,
    rm.id as room_id,
    rm.name as room_name,
    rm.floor,
    DATE(o.created_at) as date,
    COUNT(DISTINCT t.id) as total_tables,
    COUNT(DISTINCT o.id) as total_orders
FROM rooms rm
LEFT JOIN tables t ON rm.id = t.room_id
LEFT JOIN orders o ON rm.id = o.room_id
GROUP BY rm.establishment_id, rm.id, rm.name, rm.floor, DATE(o.created_at);

-- ============================================================================
-- 3. TABLES (Mesas)
-- ============================================================================

CREATE OR REPLACE VIEW view_tables_status AS
SELECT 
    rm.establishment_id,
    DATE(o.created_at) as date,
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
    DATE(o.created_at) as date,
    t.capacity,
    COUNT(t.id) as total_tables,
    COUNT(o.id) as occupied_tables
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
GROUP BY rm.establishment_id, DATE(o.created_at), t.capacity
ORDER BY t.capacity ASC;

-- ============================================================================
-- 4. STAFF (Personal)
-- ============================================================================

CREATE OR REPLACE VIEW view_staff_performance AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    u.id as user_id,
    u.name as waiter_name,
    COUNT(DISTINCT o.id) as orders_served,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue_generated
FROM users u
LEFT JOIN orders o ON u.id = o.waiter_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
WHERE u.role = 'waiter'
GROUP BY o.establishment_id, DATE(o.created_at), u.id, u.name;

CREATE OR REPLACE VIEW view_staff_zones AS
SELECT
    r.establishment_id,
    DATE(o.created_at) as date,
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
GROUP BY r.establishment_id, DATE(o.created_at), wz.id, wz.user_id, u.name, wz.room_id, r.name;

CREATE OR REPLACE VIEW view_staff_activity_log AS
SELECT 
    o.establishment_id,
    DATE(osh.changed_at) as date,
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
    DATE(aa.created_at) as date,
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

-- ============================================================================
-- 5. ALLERGENS (Alérgenos)
-- ============================================================================

CREATE OR REPLACE VIEW view_allergens_frequency AS
SELECT 
    e.id as establishment_id,
    DATE(ev.event_start) as date,
    a.eu_number,
    a.code,
    a.name_es,
    COUNT(ca.comensal_id) as comensals_count
FROM allergens a
LEFT JOIN comensal_allergens ca ON a.id = ca.allergen_id
LEFT JOIN comensals c ON ca.comensal_id = c.id
LEFT JOIN events ev ON c.event_id = ev.id
LEFT JOIN rooms rm ON ev.room_id = rm.id
LEFT JOIN establishments e ON rm.establishment_id = e.id
GROUP BY e.id, DATE(ev.event_start), a.id, a.eu_number, a.code, a.name_es
ORDER BY a.eu_number ASC;

CREATE OR REPLACE VIEW view_allergens_alerts_recent AS
SELECT 
    o.establishment_id,
    DATE(aa.created_at) as date,
    aa.id,
    to_char(aa.created_at, 'HH24:MI') as time,
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

-- POSTGREST GRANTS (Just in case)
GRANT SELECT ON view_sales_weekly_revenue TO web_anon;
GRANT SELECT ON view_sales_by_establishment TO web_anon;
GRANT SELECT ON view_sales_by_category TO web_anon;
GRANT SELECT ON view_sales_top_dishes TO web_anon;
GRANT SELECT ON view_orders_hourly TO web_anon;
GRANT SELECT ON view_orders_room_performance TO web_anon;
GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_tables_size_distribution TO web_anon;
GRANT SELECT ON view_staff_performance TO web_anon;
GRANT SELECT ON view_staff_zones TO web_anon;
GRANT SELECT ON view_staff_activity_log TO web_anon;
GRANT SELECT ON view_allergens_frequency TO web_anon;
GRANT SELECT ON view_allergens_alerts_recent TO web_anon;

