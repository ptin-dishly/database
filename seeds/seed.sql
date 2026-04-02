-- Insertar los 14 alérgenos oficiales de la UE (Reglamento 1169/2011)
INSERT INTO allergens (code, name_es, name_ca, name_en, eu_number) VALUES
    ('GLU', 'Gluten', 'Gluten', 'Gluten', 1),
    ('CRU', 'Crustáceos', 'Crustacis', 'Crustaceans', 2),
    ('HUE', 'Huevos', 'Ous', 'Eggs', 3),
    ('PES', 'Pescado', 'Peix', 'Fish', 4),
    ('CAC', 'Cacahuetes', 'Cacauets', 'Peanuts', 5),
    ('SOJ', 'Soja', 'Soja', 'Soybeans', 6),
    ('LAC', 'Lácteos (Leche)', 'Llet', 'Milk', 7),
    ('FRU', 'Frutos de cáscara', 'Fruits de closca', 'Tree nuts', 8),
    ('API', 'Apio', 'Api', 'Celery', 9),
    ('MOS', 'Mostaza', 'Mostassa', 'Mustard', 10),
    ('SES', 'Sésamo', 'Sèsam', 'Sesame', 11),
    ('SUL', 'Sulfitos', 'Sulfits', 'Sulphites', 12),
    ('ALT', 'Altramuces', 'Tramussos', 'Lupins', 13),
    ('MOL', 'Moluscos', 'Mol·luscs', 'Molluscs', 14)
--AC3 (no clonar codigo)
ON CONFLICT (code) DO NOTHING;
