-- ============================================================================
-- Migration 000017 — More Dashboard Analytics Views (DOWN)
-- ============================================================================

REVOKE SELECT ON view_staff_zones FROM web_anon;
REVOKE SELECT ON view_staff_activity_log FROM web_anon;
-- view_tables_status was originally granted in 000015, we only replace it here. We don't revoke it.
REVOKE SELECT ON view_allergens_heatmap FROM web_anon;
REVOKE SELECT ON view_allergens_presence FROM web_anon;
REVOKE SELECT ON view_allergens_alerts_recent FROM web_anon;
REVOKE SELECT ON view_allergens_alternatives FROM web_anon;

DROP VIEW IF EXISTS view_allergens_alternatives;
DROP VIEW IF EXISTS view_allergens_alerts_recent;
DROP VIEW IF EXISTS view_allergens_presence;
DROP VIEW IF EXISTS view_allergens_heatmap;
DROP VIEW IF EXISTS view_staff_activity_log;
DROP VIEW IF EXISTS view_staff_zones;

-- Revert view_tables_status to its 000015 version
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
