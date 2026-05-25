-- Fix: view_tables_status returns N rows per table when a table has N active orders.
-- LEFT JOIN orders without DISTINCT ON causes duplicate table cards in the dashboard.
-- Solution: DISTINCT ON (t.id) keeping the most recent active order per table.
-- Also fix view_tables_size_distribution: COUNT(t.id) -> COUNT(DISTINCT t.id).

DROP VIEW IF EXISTS view_tables_status;
CREATE OR REPLACE VIEW view_tables_status AS
SELECT DISTINCT ON (t.id)
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
LEFT JOIN users u ON o.waiter_id = u.id
ORDER BY t.id, o.created_at DESC NULLS LAST;

DROP VIEW IF EXISTS view_tables_size_distribution;
CREATE OR REPLACE VIEW view_tables_size_distribution AS
SELECT
    rm.establishment_id,
    (NOW() AT TIME ZONE 'Europe/Madrid')::date as date,
    t.capacity,
    COUNT(DISTINCT t.id) as total_tables,
    COUNT(DISTINCT o.table_id) as occupied_tables
FROM tables t
JOIN rooms rm ON t.room_id = rm.id
LEFT JOIN orders o ON t.id = o.table_id AND o.status IN ('pending', 'confirmed', 'preparing')
GROUP BY rm.establishment_id, t.capacity
ORDER BY t.capacity ASC;

GRANT SELECT ON view_tables_status TO web_anon;
GRANT SELECT ON view_tables_size_distribution TO web_anon;
