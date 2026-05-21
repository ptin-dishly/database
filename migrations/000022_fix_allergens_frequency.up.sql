-- ============================================================================
-- Migration 000022 — Fix view_allergens_frequency to rely on alerts and walk-ins
-- ============================================================================

CREATE OR REPLACE VIEW view_allergens_frequency AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    a.eu_number,
    a.code,
    a.name_es,
    COUNT(aa.id) as comensals_count
FROM allergens a
JOIN allergen_alerts aa ON a.id = aa.allergen_id
JOIN order_items oi ON aa.order_item_id = oi.id
JOIN orders o ON oi.order_id = o.id
GROUP BY o.establishment_id, DATE(o.created_at), a.id, a.eu_number, a.code, a.name_es;

GRANT SELECT ON view_allergens_frequency TO web_anon;
