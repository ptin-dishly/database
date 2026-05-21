-- ============================================================================
-- Migration 000021 — Missing Dashboard Views
-- ============================================================================

-- 1. Ticket distribution
CREATE OR REPLACE VIEW view_sales_ticket_distribution AS
WITH order_totals AS (
    SELECT 
        o.id as order_id,
        o.establishment_id,
        DATE(o.created_at) as date,
        COALESCE(SUM(oi.quantity * mci.price), 0) as total
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
    GROUP BY o.id, o.establishment_id, DATE(o.created_at)
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

-- 2. Orders Pipeline
CREATE OR REPLACE VIEW view_orders_pipeline AS
SELECT 
    establishment_id,
    DATE(created_at) as date,
    status as stage,
    COUNT(*) as count
FROM orders
GROUP BY establishment_id, DATE(created_at), status;

-- 3. Orders Feed
CREATE OR REPLACE VIEW view_orders_feed AS
SELECT 
    o.id,
    o.establishment_id,
    DATE(o.created_at) as date,
    to_char(o.created_at, 'HH24:MI') as time,
    t.table_number as table_name,
    o.status,
    (SELECT string_agg(quantity || 'x ' || name, ', ') 
     FROM order_items oi WHERE oi.order_id = o.id) as summary
FROM orders o
LEFT JOIN tables t ON o.table_id = t.id
ORDER BY o.created_at DESC;

-- 4. Top Cancellations
CREATE OR REPLACE VIEW view_orders_top_cancellations AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    oi.name as dish,
    COUNT(*) as quantity,
    'Cancelado' as reason
FROM order_items oi
JOIN orders o ON oi.order_id = o.id
WHERE oi.status = 'cancelled' OR o.status = 'cancelled'
GROUP BY o.establishment_id, DATE(o.created_at), oi.name;


-- Permissions
GRANT SELECT ON view_sales_ticket_distribution TO web_anon;
GRANT SELECT ON view_orders_pipeline TO web_anon;
GRANT SELECT ON view_orders_feed TO web_anon;
GRANT SELECT ON view_orders_top_cancellations TO web_anon;
