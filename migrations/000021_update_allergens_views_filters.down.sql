DROP VIEW IF EXISTS view_allergens_heatmap;
DROP VIEW IF EXISTS view_allergens_presence;
DROP VIEW IF EXISTS view_allergens_alternatives;

-- Revert to static views (simplified from original)
CREATE OR REPLACE VIEW view_allergens_heatmap AS
SELECT 
    r.id as recipe_id,
    r.name as dish_name,
    jsonb_object_agg(a.code, CASE WHEN ra.contains THEN 'C' ELSE 'T' END) as allergens
FROM recipes r
JOIN recipe_allergens ra ON r.id = ra.recipe_id
JOIN allergens a ON ra.allergen_id = a.id
GROUP BY r.id, r.name;

CREATE OR REPLACE VIEW view_allergens_presence AS
SELECT 
    CASE WHEN contains THEN 'Contiene' ELSE 'Trazas' END as label,
    COUNT(*) as value
FROM recipe_allergens
GROUP BY contains;

CREATE OR REPLACE VIEW view_allergens_alternatives AS
SELECT 
    r1.name as original,
    (SELECT array_agg(a.name_es) FROM recipe_allergens ra JOIN allergens a ON ra.allergen_id = a.id WHERE ra.recipe_id = r1.id) as original_allergens,
    r2.name as replacement,
    ralt.reason
FROM recipe_alternatives ralt
JOIN recipes r1 ON ralt.recipe_id = r1.id
JOIN recipes r2 ON ralt.alternative_recipe_id = r2.id;
