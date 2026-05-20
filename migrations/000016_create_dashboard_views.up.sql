-- ============================================================================
-- Migration 000015 — Dashboard Analytics Views
-- ============================================================================

-- ============================================================================
-- 1. SALES (Ventas)
-- ============================================================================

-- Ingresos de los últimos 7 días
CREATE OR REPLACE VIEW view_sales_weekly_revenue AS
SELECT 
    DATE(o.created_at) as order_date,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
WHERE o.created_at >= CURRENT_DATE - INTERVAL '6 days'
GROUP BY DATE(o.created_at)
ORDER BY order_date ASC;

-- Ingresos por establecimiento
CREATE OR REPLACE VIEW view_sales_by_establishment AS
SELECT 
    e.name as establishment_name,
    e.address,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue,
    COUNT(DISTINCT o.id) as total_orders
FROM establishments e
LEFT JOIN orders o ON e.id = o.establishment_id
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY e.id, e.name, e.address;

-- Ingresos por categoría de plato
CREATE OR REPLACE VIEW view_sales_by_category AS
SELECT 
    r.category as category_name,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY r.category;

-- Top 10 Platos por Facturación
CREATE OR REPLACE VIEW view_sales_top_dishes AS
SELECT 
    oi.name as dish_name,
    r.category as category_name,
    mci.price as price,
    SUM(oi.quantity) as qty_sold,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue
FROM order_items oi
JOIN recipes r ON oi.recipe_id = r.id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
GROUP BY oi.name, r.category, mci.price
ORDER BY revenue DESC
LIMIT 10;

-- ============================================================================
-- 2. ORDERS (Pedidos)
-- ============================================================================

-- Pedidos agrupados por hora (Solo del día actual)
CREATE OR REPLACE VIEW view_orders_hourly AS
SELECT 
    EXTRACT(HOUR FROM created_at) as hour_of_day,
    COUNT(*) as total_orders,
    COUNT(*) FILTER (WHERE status = 'served') as served_orders,
    COUNT(*) FILTER (WHERE status IN ('pending', 'confirmed', 'preparing')) as active_orders
FROM orders
WHERE DATE(created_at) = CURRENT_DATE
GROUP BY EXTRACT(HOUR FROM created_at)
ORDER BY hour_of_day ASC;

-- Rendimiento por sala
CREATE OR REPLACE VIEW view_orders_room_performance AS
SELECT 
    rm.id as room_id,
    rm.name as room_name,
    rm.floor,
    COUNT(DISTINCT t.id) as total_tables,
    COUNT(DISTINCT o.id) as total_orders
FROM rooms rm
LEFT JOIN tables t ON rm.id = t.room_id
LEFT JOIN orders o ON rm.id = o.room_id AND DATE(o.created_at) = CURRENT_DATE
GROUP BY rm.id, rm.name, rm.floor;

-- ============================================================================
-- 3. TABLES (Mesas)
-- ============================================================================

-- Estado de cada mesa en tiempo real
CREATE OR REPLACE VIEW view_tables_status AS
SELECT 
    t.id as table_id,
    t.table_number,
    t.capacity,
    rm.name as room_name,
    CASE 
        WHEN o.id IS NOT NULL THEN 'occupied'
        ELSE 'free' 
    END as status,
    u.name as waiter_name,
    o.created_at as occupied_since
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
LEFT JOIN users u ON o.waiter_id = u.id;

-- Distribución por tamaño de mesa
CREATE OR REPLACE VIEW view_tables_size_distribution AS
SELECT 
    t.capacity,
    COUNT(t.id) as total_tables,
    COUNT(o.id) as occupied_tables
FROM tables t
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
GROUP BY t.capacity
ORDER BY t.capacity ASC;

-- ============================================================================
-- 4. STAFF (Personal)
-- ============================================================================

-- Rendimiento del personal (Pedidos y facturación de hoy)
CREATE OR REPLACE VIEW view_staff_performance AS
SELECT 
    u.id as user_id,
    u.name as waiter_name,
    COUNT(DISTINCT o.id) as orders_served,
    COALESCE(SUM(oi.quantity * mci.price), 0) as revenue_generated
FROM users u
LEFT JOIN orders o ON u.id = o.waiter_id AND DATE(o.created_at) = CURRENT_DATE
LEFT JOIN order_items oi ON o.id = oi.order_id
LEFT JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
WHERE u.role = 'waiter'
GROUP BY u.id, u.name;

-- ============================================================================
-- 5. ALLERGENS (Alérgenos)
-- ============================================================================

-- Frecuencia de los 14 alérgenos de la UE
CREATE OR REPLACE VIEW view_allergens_frequency AS
SELECT 
    a.eu_number,
    a.code,
    a.name_es,
    COUNT(ca.comensal_id) as comensals_count
FROM allergens a
LEFT JOIN comensal_allergens ca ON a.id = ca.allergen_id
GROUP BY a.id, a.eu_number, a.code, a.name_es
ORDER BY a.eu_number ASC;

-- ============================================================================
-- 6. PERMISOS PARA POSTGREST (web_anon)
-- ============================================================================
GRANT SELECT ON view_sales_weekly_revenue TO web_anon;
GRANT SELECT ON view_sales_by_establishment TO web_anon;
GRANT SELECT ON view_sales_by_category TO web_anon;
GRANT SELECT ON view_sales_top_dishes TO web_anon;
GRANT SELECT ON view_orders_hourly TO web_anon;
GRANT SELECT ON view_orders_room_performance TO web_anon;
GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_tables_size_distribution TO web_anon;
GRANT SELECT ON view_staff_performance TO web_anon;
GRANT SELECT ON view_allergens_frequency TO web_anon;
