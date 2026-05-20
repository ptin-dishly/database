-- ============================================================================
-- Migration 000017 — More Dashboard Analytics Views
-- ============================================================================

-- ============================================================================
-- 1. STAFF (Personal)
-- ============================================================================

-- Asignación de Zonas
CREATE OR REPLACE VIEW view_staff_zones AS
SELECT
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
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing') AND DATE(o.created_at) = CURRENT_DATE
GROUP BY wz.id, wz.user_id, u.name, wz.room_id, r.name;

-- Log de actividad reciente (Cancelaciones y Alertas)
CREATE OR REPLACE VIEW view_staff_activity_log AS
SELECT 
    osh.id,
    osh.changed_at as time,
    u.name as user_name,
    'Cambió pedido a ' || osh.new_status as action,
    CASE WHEN osh.new_status = 'cancelled' THEN 'warning' ELSE 'info' END as type
FROM order_status_history osh
LEFT JOIN orders o ON osh.order_id = o.id
LEFT JOIN users u ON o.waiter_id = u.id
WHERE osh.new_status IN ('cancelled', 'served')
UNION ALL
SELECT
    aa.id,
    aa.created_at as time,
    u.name as user_name,
    'Alerta: ' || aa.message as action,
    'alert' as type
FROM allergen_alerts aa
LEFT JOIN users u ON aa.resolved_by = u.id
ORDER BY time DESC LIMIT 20;

-- ============================================================================
-- 2. TABLES (Mesas) - Actualización
-- ============================================================================

-- Estado de cada mesa en tiempo real (Añadido comensales)
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
    o.created_at as occupied_since,
    (SELECT SUM(quantity) FROM order_items WHERE order_id = o.id) as diners
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
LEFT JOIN users u ON o.waiter_id = u.id;

-- ============================================================================
-- 3. ALLERGENS (Alérgenos)
-- ============================================================================

-- Mapa de calor (JSON)
CREATE OR REPLACE VIEW view_allergens_heatmap AS
SELECT 
    r.id as recipe_id,
    r.name as dish_name,
    jsonb_object_agg(a.code, CASE WHEN ra.contains THEN 'C' ELSE 'T' END) as allergens
FROM recipes r
JOIN recipe_allergens ra ON r.id = ra.recipe_id
JOIN allergens a ON ra.allergen_id = a.id
GROUP BY r.id, r.name;

-- Distribución de presencia
CREATE OR REPLACE VIEW view_allergens_presence AS
SELECT 
    CASE WHEN contains THEN 'Contiene' ELSE 'Trazas' END as label,
    COUNT(*) as value
FROM recipe_allergens
GROUP BY contains;

-- Alertas recientes (Historial)
CREATE OR REPLACE VIEW view_allergens_alerts_recent AS
SELECT 
    aa.id,
    to_char(aa.created_at, 'HH24:MI') as time,
    CASE WHEN DATE(aa.created_at) = CURRENT_DATE THEN 'Hoy' ELSE to_char(aa.created_at, 'DD/MM') END as date,
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

-- Alternativas sugeridas
CREATE OR REPLACE VIEW view_allergens_alternatives AS
SELECT 
    r1.name as original,
    (SELECT array_agg(a.name_es) FROM recipe_allergens ra JOIN allergens a ON ra.allergen_id = a.id WHERE ra.recipe_id = r1.id) as original_allergens,
    r2.name as replacement,
    ralt.reason
FROM recipe_alternatives ralt
JOIN recipes r1 ON ralt.recipe_id = r1.id
JOIN recipes r2 ON ralt.alternative_recipe_id = r2.id;


-- ============================================================================
-- 4. PERMISOS PARA POSTGREST (web_anon)
-- ============================================================================
GRANT SELECT ON view_staff_zones TO web_anon;
GRANT SELECT ON view_staff_activity_log TO web_anon;
GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_allergens_heatmap TO web_anon;
GRANT SELECT ON view_allergens_presence TO web_anon;
GRANT SELECT ON view_allergens_alerts_recent TO web_anon;
GRANT SELECT ON view_allergens_alternatives TO web_anon;
