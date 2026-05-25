-- Revert to pre-dedup views (from migration 000027)

DROP VIEW IF EXISTS view_tables_status;
CREATE OR REPLACE VIEW view_tables_status AS
SELECT
    rm.establishment_id,
    COALESCE(DATE(o.created_at AT TIME ZONE 'Europe/Madrid'), (NOW() AT TIME ZONE 'Europe/Madrid')::date) as date,
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

DROP VIEW IF EXISTS view_tables_size_distribution;
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

GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_tables_size_distribution TO web_anon;
