-- ============================================================================
-- Migration 000020 — Make allergens views dynamic (filtered by establishment and date)
-- ============================================================================

-- DROP static views
DROP VIEW IF EXISTS view_allergens_heatmap;
DROP VIEW IF EXISTS view_allergens_presence;
DROP VIEW IF EXISTS view_allergens_alternatives;

-- Recreate view_allergens_heatmap
CREATE OR REPLACE VIEW view_allergens_heatmap AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    r.id as recipe_id,
    r.name as dish_name,
    jsonb_object_agg(a.code, CASE WHEN ra.contains THEN 'C' ELSE 'T' END) as allergens
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN recipes r ON mci.recipe_id = r.id
JOIN recipe_allergens ra ON r.id = ra.recipe_id
JOIN allergens a ON ra.allergen_id = a.id
GROUP BY o.establishment_id, DATE(o.created_at), r.id, r.name;

-- Recreate view_allergens_presence
CREATE OR REPLACE VIEW view_allergens_presence AS
SELECT 
    o.establishment_id,
    DATE(o.created_at) as date,
    CASE WHEN ra.contains THEN 'Contiene' ELSE 'Trazas' END as label,
    COUNT(*) as value
FROM orders o
JOIN order_items oi ON o.id = oi.order_id
JOIN menu_card_items mci ON oi.menu_card_item_id = mci.id
JOIN recipes r ON mci.recipe_id = r.id
JOIN recipe_allergens ra ON r.id = ra.recipe_id
GROUP BY o.establishment_id, DATE(o.created_at), ra.contains;

-- Recreate view_allergens_alternatives
CREATE OR REPLACE VIEW view_allergens_alternatives AS
SELECT DISTINCT
    o.establishment_id,
    DATE(o.created_at) as date,
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

GRANT SELECT ON view_allergens_heatmap TO web_anon;
GRANT SELECT ON view_allergens_presence TO web_anon;
GRANT SELECT ON view_allergens_alternatives TO web_anon;
