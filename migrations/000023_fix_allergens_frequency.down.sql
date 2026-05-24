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
