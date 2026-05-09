-- ============================================================================
-- SEED DATA — Dishly (MEGA UPDATE CAL BLAY + FULL CORE DATA)
-- Orden: allergens → ingredients → establishments → users → rooms → tables →
--         seats → recipes → menu_cards → events → comensals → orders → ...
-- ============================================================================

-- ============================================================================
-- 1. ALLERGENS (14 oficials UE)
-- ============================================================================
INSERT INTO allergens (code, name_es, name_ca, name_en, eu_number) VALUES
    ('GLU', 'Gluten',              'Gluten',            'Gluten',      1),
    ('CRU', 'Crustáceos',          'Crustacis',         'Crustaceans', 2),
    ('HUE', 'Huevos',              'Ous',               'Eggs',        3),
    ('PES', 'Pescado',             'Peix',              'Fish',        4),
    ('CAC', 'Cacahuetes',          'Cacauets',          'Peanuts',     5),
    ('SOJ', 'Soja',                'Soja',              'Soybeans',    6),
    ('LAC', 'Lácteos (Leche)',     'Llet',              'Milk',        7),
    ('FRU', 'Frutos de cáscara',   'Fruits de closca',  'Tree nuts',   8),
    ('API', 'Apio',                'Api',               'Celery',      9),
    ('MOS', 'Mostaza',             'Mostassa',          'Mustard',     10),
    ('SES', 'Sésamo',              'Sèsam',             'Sesame',      11),
    ('SUL', 'Sulfitos',            'Sulfits',           'Sulphites',   12),
    ('ALT', 'Altramuces',          'Tramussos',         'Lupins',      13),
    ('MOL', 'Moluscos',            'Mol·luscs',         'Molluscs',    14)
ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- 2. INGREDIENTS (Originales + Bases Cal Blay)
-- ============================================================================
INSERT INTO ingredients (id, name, description, is_active) VALUES
    -- Originales
    ('11111111-0001-0001-0001-000000000001', 'Harina de trigo',    'Harina de trigo común',         TRUE),
    ('11111111-0001-0001-0001-000000000002', 'Huevo',              'Huevo fresco de gallina',       TRUE),
    ('11111111-0001-0001-0001-000000000003', 'Leche entera',       'Leche entera pasteurizada',     TRUE),
    ('11111111-0001-0001-0001-000000000004', 'Mantequilla',        'Mantequilla sin sal',           TRUE),
    ('11111111-0001-0001-0001-000000000005', 'Tomate',             'Tomate fresco maduro',          TRUE),
    ('11111111-0001-0001-0001-000000000006', 'Cebolla',            'Cebolla blanca',                TRUE),
    ('11111111-0001-0001-0001-000000000007', 'Ajo',                'Ajo fresco',                    TRUE),
    ('11111111-0001-0001-0001-000000000008', 'Aceite de oliva',    'Aceite de oliva virgen extra',  TRUE),
    ('11111111-0001-0001-0001-000000000009', 'Sal',                'Sal marina',                    TRUE),
    ('11111111-0001-0001-0001-000000000010', 'Pimienta negra',     'Pimienta negra molida',         TRUE),
    ('11111111-0001-0001-0001-000000000011', 'Pechuga de pollo',   'Pechuga de pollo fresca',       TRUE),
    ('11111111-0001-0001-0001-000000000012', 'Salmón fresco',      'Salmón atlántico fresco',       TRUE),
    ('11111111-0001-0001-0001-000000000013', 'Pasta lasaña',       'Láminas de pasta para lasaña',  TRUE),
    ('11111111-0001-0001-0001-000000000014', 'Carne picada mixta', 'Mezcla de cerdo y ternera',     TRUE),
    ('11111111-0001-0001-0001-000000000015', 'Queso parmesano',    'Parmigiano Reggiano',           TRUE),
    ('11111111-0001-0001-0001-000000000016', 'Nata líquida',       'Nata para cocinar 35% MG',      TRUE),
    ('11111111-0001-0001-0001-000000000017', 'Limón',              'Limón fresco',                  TRUE),
    ('11111111-0001-0001-0001-000000000018', 'Perejil',            'Perejil fresco',                TRUE),
    ('11111111-0001-0001-0001-000000000019', 'Patata',             'Patata agria',                  TRUE),
    ('11111111-0001-0001-0001-000000000020', 'Azúcar',             'Azúcar blanco refinado',        TRUE),
    -- Genéricos Cal Blay para no romper FKs
    ('11111111-0001-0001-0001-000000000021', 'Peix Fresc',         'Llobarro, salmó, tonyina...',   TRUE),
    ('11111111-0001-0001-0001-000000000022', 'Marisc',             'Gambes, escamarlans, musclos',  TRUE),
    ('11111111-0001-0001-0001-000000000023', 'Carn de Vedella',    'Vedella i Rubia Gallega',       TRUE),
    ('11111111-0001-0001-0001-000000000024', 'Carn de Porc',       'Ibèric, pernil, carn de perol', TRUE),
    ('11111111-0001-0001-0001-000000000025', 'Au',                 'Gall del Penedès, Pollastre',   TRUE),
    ('11111111-0001-0001-0001-000000000026', 'Heura / Soja',       'Proteïna vegetal',              TRUE),
    ('11111111-0001-0001-0001-000000000027', 'Fruits secs',        'Ametlles, pinyons, avellanes',  TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 3. INGREDIENT ALLERGENS
-- ============================================================================
INSERT INTO ingredient_allergens (ingredient_id, allergen_id, presence) VALUES
    ('11111111-0001-0001-0001-000000000001', (SELECT id FROM allergens WHERE code='GLU'), 'contains'),
    ('11111111-0001-0001-0001-000000000002', (SELECT id FROM allergens WHERE code='HUE'), 'contains'),
    ('11111111-0001-0001-0001-000000000003', (SELECT id FROM allergens WHERE code='LAC'), 'contains'),
    ('11111111-0001-0001-0001-000000000004', (SELECT id FROM allergens WHERE code='LAC'), 'contains'),
    ('11111111-0001-0001-0001-000000000013', (SELECT id FROM allergens WHERE code='GLU'), 'contains'),
    ('11111111-0001-0001-0001-000000000015', (SELECT id FROM allergens WHERE code='LAC'), 'contains'),
    ('11111111-0001-0001-0001-000000000016', (SELECT id FROM allergens WHERE code='LAC'), 'contains'),
    ('11111111-0001-0001-0001-000000000012', (SELECT id FROM allergens WHERE code='PES'), 'contains')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 4. ESTABLISHMENTS
-- ============================================================================
INSERT INTO establishments (id, name, address, phone, email, is_active) VALUES
    ('22222222-0002-0002-0002-000000000001', 'Restaurant Ca la Maria',  'Carrer Major, 12, Barcelona',      '931234567', 'info@calamaria.cat', TRUE),
    ('22222222-0002-0002-0002-000000000002', 'Bistró El Racó',          'Passeig de Gràcia, 45, Barcelona', '932345678', 'hola@elraco.cat',   TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 5. USERS
-- ============================================================================
INSERT INTO users (id, establishment_id, email, password_hash, name, role, is_active) VALUES
    ('33333333-0003-0003-0003-000000000001', '22222222-0002-0002-0002-000000000001', 'admin@calamaria.cat',   '$2b$10$placeholder.hash.admin1', 'Maria Puig',   'admin',   TRUE),
    ('33333333-0003-0003-0003-000000000002', '22222222-0002-0002-0002-000000000001', 'waiter1@calamaria.cat', '$2b$10$placeholder.hash.wait1',  'Joan Ferrer',  'waiter',  TRUE),
    ('33333333-0003-0003-0003-000000000003', '22222222-0002-0002-0002-000000000001', 'kitchen@calamaria.cat', '$2b$10$placeholder.hash.kit1',   'Pere Roca',    'kitchen', TRUE),
    ('33333333-0003-0003-0003-000000000004', '22222222-0002-0002-0002-000000000001', 'sales@calamaria.cat',   '$2b$10$placeholder.hash.sal1',   'Anna Vidal',   'sales',   TRUE),
    ('33333333-0003-0003-0003-000000000005', '22222222-0002-0002-0002-000000000002', 'admin@elraco.cat',      '$2b$10$placeholder.hash.admin2', 'Pau Domènech', 'admin',   TRUE),
    ('33333333-0003-0003-0003-000000000006', '22222222-0002-0002-0002-000000000002', 'waiter2@elraco.cat',    '$2b$10$placeholder.hash.wait2',  'Laia Mas',     'waiter',  TRUE),
    -- TEST USERS
    ('99999999-9999-9999-9999-000000000001', '22222222-0002-0002-0002-000000000001', 'test.admin@dishly.dev',   '$2b$10$FShFCgq.WgHdcswfqT4/QusZBgyVjFzbdMaTlpA31X8iGdUJz7l9O', 'Test Admin',   'admin',   TRUE),
    ('99999999-9999-9999-9999-000000000002', '22222222-0002-0002-0002-000000000001', 'test.sales@dishly.dev',   '$2b$10$.r6LC3nBqWVjC30a9PZ50.noWiyniw0y302GaIHlHR1fIEnvE0goa',  'Test Sales',   'sales',   TRUE),
    ('99999999-9999-9999-9999-000000000003', '22222222-0002-0002-0002-000000000001', 'test.waiter@dishly.dev',  '$2b$10$i2qnzTwbJ1eQqEgPYrmfUevQn4LjxzPYGgOy/ZbCRPw13fQRKnFO2', 'Test Waiter',  'waiter',  TRUE),
    ('99999999-9999-9999-9999-000000000004', '22222222-0002-0002-0002-000000000001', 'test.kitchen@dishly.dev', '$2b$10$ojEqS21bLyRsXWxsjcOozOi6Ebbm.VzqU1t94Exxc.oFHHEED0CYq', 'Test Kitchen', 'kitchen', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 6. ROOMS
-- ============================================================================
INSERT INTO rooms (id, establishment_id, name, capacity, floor) VALUES
    ('44444444-0004-0004-0004-000000000001', '22222222-0002-0002-0002-000000000001', 'Sala Principal', 40, 0),
    ('44444444-0004-0004-0004-000000000002', '22222222-0002-0002-0002-000000000001', 'Terrassa',       20, 0),
    ('44444444-0004-0004-0004-000000000003', '22222222-0002-0002-0002-000000000002', 'Sala Única',     30, 1)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 7. TABLES
-- ============================================================================
INSERT INTO tables (id, room_id, table_number, capacity) VALUES
    ('55555555-0005-0005-0005-000000000001', '44444444-0004-0004-0004-000000000001', '1', 4),
    ('55555555-0005-0005-0005-000000000002', '44444444-0004-0004-0004-000000000001', '2', 4),
    ('55555555-0005-0005-0005-000000000003', '44444444-0004-0004-0004-000000000001', '3', 6),
    ('55555555-0005-0005-0005-000000000004', '44444444-0004-0004-0004-000000000002', '4', 2),
    ('55555555-0005-0005-0005-000000000005', '44444444-0004-0004-0004-000000000002', '5', 4),
    ('55555555-0005-0005-0005-000000000006', '44444444-0004-0004-0004-000000000003', '1', 4),
    ('55555555-0005-0005-0005-000000000007', '44444444-0004-0004-0004-000000000003', '2', 6)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 8. SEATS (MIGRADO A COMENSAL_NAME - OBJETIVO MAIG 10)
-- ============================================================================
INSERT INTO seats (id, table_id, comensal_name, label) VALUES
    -- Mesa 1 (4 seats)
    ('66666666-0006-0006-0006-000000000001', '55555555-0005-0005-0005-000000000001', 'Comensal 1', 'A'),
    ('66666666-0006-0006-0006-000000000002', '55555555-0005-0005-0005-000000000001', 'Comensal 2', 'B'),
    ('66666666-0006-0006-0006-000000000003', '55555555-0005-0005-0005-000000000001', 'Comensal 3', 'C'),
    ('66666666-0006-0006-0006-000000000004', '55555555-0005-0005-0005-000000000001', 'Comensal 4', 'D'),
    -- Mesa 2 (4 seats)
    ('66666666-0006-0006-0006-000000000005', '55555555-0005-0005-0005-000000000002', 'Comensal 5', 'A'),
    ('66666666-0006-0006-0006-000000000006', '55555555-0005-0005-0005-000000000002', 'Comensal 6', 'B'),
    ('66666666-0006-0006-0006-000000000007', '55555555-0005-0005-0005-000000000002', 'Comensal 7', 'C'),
    ('66666666-0006-0006-0006-000000000008', '55555555-0005-0005-0005-000000000002', 'Comensal 8', 'D'),
    -- Mesa 3 (6 seats - Evento Garcia)
    ('66666666-0006-0006-0006-000000000009', '55555555-0005-0005-0005-000000000003', 'Josep', 'A'),
    ('66666666-0006-0006-0006-000000000010', '55555555-0005-0005-0005-000000000003', 'Montse', 'B'),
    ('66666666-0006-0006-0006-000000000011', '55555555-0005-0005-0005-000000000003', 'Pau', 'C'),
    ('66666666-0006-0006-0006-000000000012', '55555555-0005-0005-0005-000000000003', 'Laura', 'D'),
    ('66666666-0006-0006-0006-000000000013', '55555555-0005-0005-0005-000000000003', 'Marc', 'E'),
    ('66666666-0006-0006-0006-000000000014', '55555555-0005-0005-0005-000000000003', 'Invitado', 'F')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 9. RECIPES (ORIGINALES + MASIVA DE CAL BLAY)
-- ============================================================================
INSERT INTO recipes (id, establishment_id, name, description, category, portion_size_kg, servings, preparation_time, version, created_by) VALUES
    -- Originales (Para no romper comandas antiguas)
    ('77777777-0007-0007-0007-000000000001', '22222222-0002-0002-0002-000000000001', 'Lasaña de carne',     'Lasaña tradicional', 'segundo_plato', 0.400, 1, 60, 1, '33333333-0003-0003-0003-000000000001'),
    ('77777777-0007-0007-0007-000000000002', '22222222-0002-0002-0002-000000000001', 'Salmón a la plancha', 'Salmón con limón', 'segundo_plato', 0.250, 1, 20, 1, '33333333-0003-0003-0003-000000000001'),
    ('77777777-0007-0007-0007-000000000003', '22222222-0002-0002-0002-000000000001', 'Ensalada César',      'Ensalada con pollo', 'entrante',      0.300, 1, 15, 1, '33333333-0003-0003-0003-000000000001'),
    ('77777777-0007-0007-0007-000000000004', '22222222-0002-0002-0002-000000000001', 'Crema catalana',      'Postre tradicional', 'postre',        0.150, 1, 30, 1, '33333333-0003-0003-0003-000000000001'),
    ('77777777-0007-0007-0007-000000000005', '22222222-0002-0002-0002-000000000002', 'Pollo al ajillo',     'Pollo con ajo',      'segundo_plato', 0.350, 1, 35, 1, '33333333-0003-0003-0003-000000000005'),
    ('77777777-0007-0007-0007-000000000006', '22222222-0002-0002-0002-000000000002', 'Patatas bravas',      'Con salsa brava',    'entrante',      0.200, 1, 25, 1, '33333333-0003-0003-0003-000000000005'),
    ('77777777-0007-0007-0007-000000000007', '22222222-0002-0002-0002-000000000001', 'Salsa bechamel',      'Base para lasaña',   'salsa',         0.100, 4, 15, 1, '33333333-0003-0003-0003-000000000001'),

    -- Hamburguesas
    ('77777777-0007-0007-0007-000000000078', '22222222-0002-0002-0002-000000000001', 'Hamburguesa de vedella', 'Amb ceba caramel·litzada, pa de brioix i formatge', 'segundo_plato', 0.300, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000079', '22222222-0002-0002-0002-000000000001', 'Hamburguesa de Rubia Gallega', 'Amb ceba caramel·litzada, pa de brioix i formatge', 'segundo_plato', 0.350, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),

    -- Arrossos i Pasta
    ('77777777-0007-0007-0007-000000000080', '22222222-0002-0002-0002-000000000001', 'Paella de marisc', 'Amb rap, sípia, gambes i musclos', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000081', '22222222-0002-0002-0002-000000000001', 'Arròs negre', 'Amb sípia i allioli', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000082', '22222222-0002-0002-0002-000000000001', 'Arròs caldós de llamàntol', '1/2 llamàntol per persona', 'segundo_plato', 0.500, 1, 30, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000083', '22222222-0002-0002-0002-000000000001', 'Arròs de verdures', 'Amb verdures de temporada', 'segundo_plato', 0.350, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000084', '22222222-0002-0002-0002-000000000001', 'Espaguetis', 'Amb gambes, all i bitxo', 'entrante', 0.250, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000085', '22222222-0002-0002-0002-000000000001', 'Tortellini de mató', 'Amb pesto, tomàquet i olives negres', 'primer_plato', 0.250, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    
    -- Cal Blay (Entrants i Tapes)
    ('77777777-0007-0007-0007-000000000050', '22222222-0002-0002-0002-000000000001', 'Pernil D.O ibèric Los Pedroches', 'Tallat a mà', 'entrante', 0.150, 1, 5, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000051', '22222222-0002-0002-0002-000000000001', 'Anxoves dessalades a casa', 'Amb pa de coca (6u)', 'entrante', 0.200, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000052', '22222222-0002-0002-0002-000000000001', 'Bunyols de bacallà (8u)', 'La recepta clàssica', 'entrante', 0.250, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000053', '22222222-0002-0002-0002-000000000001', 'Croquetó de carn de perol', 'Tradicionals', 'entrante', 0.200, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000054', '22222222-0002-0002-0002-000000000001', 'La nostra ensaladilla cremosa', 'Amb ou ferrat i tonyina', 'entrante', 0.250, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000055', '22222222-0002-0002-0002-000000000001', 'Calamars a l''andalusa', 'Fregits', 'entrante', 0.300, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000056', '22222222-0002-0002-0002-000000000001', 'Mandonguilles amb sípia', 'Mar i muntanya', 'primer_plato', 0.350, 1, 40, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000057', '22222222-0002-0002-0002-000000000001', 'Ous estrellats', 'Amb patata, tòfona i foie', 'primer_plato', 0.400, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000058', '22222222-0002-0002-0002-000000000001', 'Tartar de tonyina Balfegó', 'Amb guacamole', 'entrante', 0.200, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000059', '22222222-0002-0002-0002-000000000001', 'Xató de Vilanova', 'Escarola, bacallà i romesco', 'entrante', 0.250, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),

    -- Més Entrants
    ('77777777-0007-0007-0007-000000000086', '22222222-0002-0002-0002-000000000001', 'Amanida de seitons en vinagre', 'Amb maduixes i formatge', 'entrante', 0.200, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000087', '22222222-0002-0002-0002-000000000001', 'Amanida de brots tendres', 'Amb cherry i formatge de cabra', 'entrante', 0.200, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000088', '22222222-0002-0002-0002-000000000001', 'Salmorejo', 'Amb pernil ibèric i ou dur', 'entrante', 0.250, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000089', '22222222-0002-0002-0002-000000000001', 'Empedrat de cigrons', 'Amb botifarra negra i pop', 'entrante', 0.250, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000090', '22222222-0002-0002-0002-000000000001', 'Musclos al vapor', 'Amb cítrics', 'entrante', 0.300, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000091', '22222222-0002-0002-0002-000000000001', 'Graellada de verdures', 'Amb salsa romesco', 'primer_plato', 0.300, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    
    -- Cal Blay (Cassoles i Arrossos)
    ('77777777-0007-0007-0007-000000000060', '22222222-0002-0002-0002-000000000001', 'Caneló de gall del Penedès', 'Amb crema de ceps', 'primer_plato', 0.350, 1, 40, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000061', '22222222-0002-0002-0002-000000000001', 'Fricandó de vedella', 'Tradicional amb moixernons', 'segundo_plato', 0.350, 1, 45, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000062', '22222222-0002-0002-0002-000000000001', 'Arròs del senyoret', 'Amb gambes, calamars i musclos', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000063', '22222222-0002-0002-0002-000000000001', 'Arròs d''ibèrics', 'Amb costella de porc Ral', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000064', '22222222-0002-0002-0002-000000000001', 'Arròs de gamba vermella', 'Amb sípia', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000065', '22222222-0002-0002-0002-000000000001', 'Suquet de peix', 'Lluç, musclos, gambes', 'segundo_plato', 0.450, 1, 30, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000066', '22222222-0002-0002-0002-000000000001', 'Mariscada', 'Gambes, escamarlans, llagostins', 'segundo_plato', 0.600, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000077', '22222222-0002-0002-0002-000000000001', 'Fideuà marinera', 'Amb allioli', 'segundo_plato', 1, '99999999-9999-9999-9999-000000000001'),

    -- Cal Blay (Carns, Peixos i Vegà)
    ('77777777-0007-0007-0007-000000000067', '22222222-0002-0002-0002-000000000001', 'Bone in Rib-Eye Rubia Gallega', 'A la brasa (2 pax)', 'segundo_plato', 1.000, 2, 30, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000068', '22222222-0002-0002-0002-000000000001', 'Txuleton de 500g', 'Amb patates fregides', 'segundo_plato', 0.500, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000069', '22222222-0002-0002-0002-000000000001', 'Turbot a la brasa', 'Amb patata confitada', 'segundo_plato', 0.400, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000070', '22222222-0002-0002-0002-000000000001', 'Pop a la brasa', 'Amb cansalada i romesco', 'segundo_plato', 0.350, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000071', '22222222-0002-0002-0002-000000000001', 'Hamburguesa vegana d''Heura', 'Amb ceba caramel·litzada', 'segundo_plato', 0.300, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000072', '22222222-0002-0002-0002-000000000001', 'Albergínia farcida amb heura', 'Amb verdures', 'segundo_plato', 0.350, 1, 30, 1, '99999999-9999-9999-9999-000000000001'),

    -- Més Carns
    ('77777777-0007-0007-0007-000000000092', '22222222-0002-0002-0002-000000000001', 'Magret d''ànec Collverd', 'A la brasa', 'segundo_plato', 0.350, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000093', '22222222-0002-0002-0002-000000000001', 'Graellada de carn', 'Xai, botifarra i pollastre', 'segundo_plato', 0.500, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000094', '22222222-0002-0002-0002-000000000001', 'Txurrasco macerat', 'Amb chimichurri', 'segundo_plato', 0.350, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000095', '22222222-0002-0002-0002-000000000001', 'Galta de porc', 'A la brasa', 'segundo_plato', 0.350, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000096', '22222222-0002-0002-0002-000000000001', 'Peus de porc a la brasa', 'Macerats al cava', 'segundo_plato', 0.400, 1, 25, 1, '99999999-9999-9999-9999-000000000001'),

    -- Més Peixos
    ('77777777-0007-0007-0007-000000000097', '22222222-0002-0002-0002-000000000001', 'Calamarcets a la planxa', 'Amb verdures i romesco', 'segundo_plato', 0.300, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000098', '22222222-0002-0002-0002-000000000001', 'Llom de lluç a l''Orio', 'Amb patata confitada', 'segundo_plato', 0.300, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000099', '22222222-0002-0002-0002-000000000001', 'Bacallà amb samfaina', 'De verdures', 'segundo_plato', 0.350, 1, 20, 1, '99999999-9999-9999-9999-000000000001'),

    -- Cal Blay (Postres)
    ('77777777-0007-0007-0007-000000000073', '22222222-0002-0002-0002-000000000001', 'Pastís de formatge cremós', 'El nostre cheesecake', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000074', '22222222-0002-0002-0002-000000000001', 'Lionesa XL farcida de nata', 'Amb xocolata Cal Simón 70%', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000075', '22222222-0002-0002-0002-000000000001', 'Tiramisú', 'Recepta autèntica italiana', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000076', '22222222-0002-0002-0002-000000000001', 'Carpaccio de pinya', 'Amb gelat de coco', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),

    -- Més Postres
    ('77777777-0007-0007-0007-000000000100', '22222222-0002-0002-0002-000000000001', 'Pastís de xocolata 70%', 'Simón Coll', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000101', '22222222-0002-0002-0002-000000000001', 'Poma tatin', 'Amb crumble i gelat', 'postre', 0.150, 1, 15, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000102', '22222222-0002-0002-0002-000000000001', 'Flam d''avellanes', 'Amb nata', 'postre', 0.150, 1, 10, 1, '99999999-9999-9999-9999-000000000001'),
    ('77777777-0007-0007-0007-000000000103', '22222222-0002-0002-0002-000000000001', 'Gelats artesans', 'Sabors variats', 'postre', 0.150, 1, 5, 1, '99999999-9999-9999-9999-000000000001')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 10. RECIPE STEPS (Mantenemos los originales)
-- ============================================================================
INSERT INTO recipe_steps (recipe_id, step_number, instruction, duration) VALUES
    ('77777777-0007-0007-0007-000000000001', 1, 'Preparar la salsa bechamel con mantequilla, harina y leche', 15),
    ('77777777-0007-0007-0007-000000000001', 2, 'Sofreír la cebolla y el ajo, añadir la carne picada y cocinar', 15),
    ('77777777-0007-0007-0007-000000000001', 3, 'Añadir el tomate triturado y cocinar la boloñesa 10 minutos', 10),
    ('77777777-0007-0007-0007-000000000001', 4, 'Montar la lasaña en capas y gratinar en el horno a 200°C', 20),
    ('77777777-0007-0007-0007-000000000002', 1, 'Salpimentar el salmón y marinar con limón 5 minutos', 5),
    ('77777777-0007-0007-0007-000000000002', 2, 'Cocinar a la plancha 4 minutos por cada lado', 8),
    ('77777777-0007-0007-0007-000000000002', 3, 'Servir con perejil picado y rodaja de limón', 2),
    ('77777777-0007-0007-0007-000000000004', 1, 'Mezclar yemas de huevo con azúcar y leche caliente', 10),
    ('77777777-0007-0007-0007-000000000004', 2, 'Cocer a fuego lento hasta espesar', 15),
    ('77777777-0007-0007-0007-000000000004', 3, 'Enfriar y caramelizar el azúcar con soplete', 5)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 11. RECIPE INGREDIENTS (Mantenemos los originales)
-- ============================================================================
INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit, is_optional) VALUES
    ('77777777-0007-0007-0007-000000000001', '11111111-0001-0001-0001-000000000013', 0.200, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000001', '11111111-0001-0001-0001-000000000014', 0.300, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000001', '11111111-0001-0001-0001-000000000005', 0.200, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000001', '11111111-0001-0001-0001-000000000015', 0.050, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000001', '11111111-0001-0001-0001-000000000006', 0.100, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000002', '11111111-0001-0001-0001-000000000012', 0.250, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000002', '11111111-0001-0001-0001-000000000017', 0.050, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000004', '11111111-0001-0001-0001-000000000002', 0.100, 'kg', FALSE),
    ('77777777-0007-0007-0007-000000000004', '11111111-0001-0001-0001-000000000003', 0.250, 'l',  FALSE),
    ('77777777-0007-0007-0007-000000000004', '11111111-0001-0001-0001-000000000020', 0.060, 'kg', FALSE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 12. RECIPE ALLERGENS (ORIGINALES + CAL BLAY)
-- ============================================================================
INSERT INTO recipe_allergens (recipe_id, allergen_id, is_manual, contains) VALUES
    -- Originales
    ('77777777-0007-0007-0007-000000000001', (SELECT id FROM allergens WHERE code='GLU'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000001', (SELECT id FROM allergens WHERE code='LAC'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000001', (SELECT id FROM allergens WHERE code='HUE'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000002', (SELECT id FROM allergens WHERE code='PES'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000003', (SELECT id FROM allergens WHERE code='LAC'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000003', (SELECT id FROM allergens WHERE code='HUE'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000004', (SELECT id FROM allergens WHERE code='LAC'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000004', (SELECT id FROM allergens WHERE code='HUE'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000007', (SELECT id FROM allergens WHERE code='GLU'), FALSE, TRUE),
    ('77777777-0007-0007-0007-000000000007', (SELECT id FROM allergens WHERE code='LAC'), FALSE, TRUE),

    -- Cal Blay (Anxoves: Peix, Gluten)
    ('77777777-0007-0007-0007-000000000051', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000051', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    
    -- Cal Blay (Bunyols de bacallà: Peix, Gluten, Ou, Lactis)
    ('77777777-0007-0007-0007-000000000052', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000052', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000052', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000052', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    
    -- Cal Blay (Croquetó i Caneló: Gluten, Ou, Lactis)
    ('77777777-0007-0007-0007-000000000053', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000053', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000053', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000060', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000060', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000060', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    
    -- Cal Blay (Ensaladilla: Ou, Peix)
    ('77777777-0007-0007-0007-000000000054', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000054', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    
    -- Cal Blay (Calamars i Mandonguilles amb sípia: Moluscos, Gluten, Ou)
    ('77777777-0007-0007-0007-000000000055', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000055', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000055', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000056', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000056', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000056', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    
    -- Cal Blay (Ous estrellats: Ou)
    ('77777777-0007-0007-0007-000000000057', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    
    -- Cal Blay (Tartar de tonyina: Peix, Soja, Sèsam)
    ('77777777-0007-0007-0007-000000000058', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000058', (SELECT id FROM allergens WHERE code='SOJ'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000058', (SELECT id FROM allergens WHERE code='SES'), TRUE, TRUE),
    
    -- Cal Blay (Xató: Peix, Fruits Secs)
    ('77777777-0007-0007-0007-000000000059', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000059', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    
    -- Cal Blay (Fricandó: Gluten)
    ('77777777-0007-0007-0007-000000000061', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    
    -- Cal Blay (Arròs Senyoret i Suquet: Crustacis, Moluscos, Peix)
    ('77777777-0007-0007-0007-000000000062', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000062', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000062', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000065', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000065', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000065', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    
    -- Cal Blay (Arròs gamba vermella: Crustacis, Moluscos, Peix)
    ('77777777-0007-0007-0007-000000000064', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000064', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000064', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    
    -- Cal Blay (Mariscada: Crustacis, Moluscos, Sulfits)
    ('77777777-0007-0007-0007-000000000066', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000066', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000066', (SELECT id FROM allergens WHERE code='SUL'), TRUE, TRUE),

    -- Cal Blay (Fideua)
    ('77777777-0007-0007-0007-000000000077', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000077', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000077', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000077', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    
    -- Cal Blay (Peixos: Turbot)
    ('77777777-0007-0007-0007-000000000069', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    
    -- Cal Blay (Pop: Moluscos, Fruits Secs)
    ('77777777-0007-0007-0007-000000000070', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000070', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    
    -- Cal Blay (Vegans amb Heura: Soja, Gluten pel pa/arrebossat)
    ('77777777-0007-0007-0007-000000000071', (SELECT id FROM allergens WHERE code='SOJ'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000071', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000072', (SELECT id FROM allergens WHERE code='SOJ'), TRUE, TRUE),
    
    -- Cal Blay (Postres: Cheesecake / Lionesa: Lactis, Ou, Gluten)
    ('77777777-0007-0007-0007-000000000073', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000073', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000073', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000074', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000074', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000074', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    
    -- Cal Blay (Tiramisú: Gluten, Lactis, Ou, Sulfits)
    ('77777777-0007-0007-0007-000000000075', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000075', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000075', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000075', (SELECT id FROM allergens WHERE code='SUL'), TRUE, TRUE),
    
    -- Cal Blay (Carpaccio de pinya: Lactis pel gelat)
    ('77777777-0007-0007-0007-000000000076', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),

    -- Hamburgueses (Gluten, Lactis, Ou)
    ('77777777-0007-0007-0007-000000000078', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000078', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000078', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000079', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000079', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000079', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    
    -- Paelles (Peix, Crustacis, Mol·luscos)
    ('77777777-0007-0007-0007-000000000080', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000080', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000080', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000081', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000081', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000081', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000082', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000082', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    
    -- Espaguetis / Tortellini
    ('77777777-0007-0007-0007-000000000084', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000084', (SELECT id FROM allergens WHERE code='CRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000085', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000085', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000085', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    
    -- Amanides i Entrants
    ('77777777-0007-0007-0007-000000000086', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000086', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000086', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000087', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000088', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000088', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000089', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000090', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000091', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000091', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    
    -- Carns (Peus de porc)
    ('77777777-0007-0007-0007-000000000096', (SELECT id FROM allergens WHERE code='SUL'), TRUE, TRUE),
    
    -- Més Peixos
    ('77777777-0007-0007-0007-000000000097', (SELECT id FROM allergens WHERE code='MOL'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000097', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000098', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000099', (SELECT id FROM allergens WHERE code='PES'), TRUE, TRUE),

    -- Més Postres
    ('77777777-0007-0007-0007-000000000100', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000100', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000100', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000101', (SELECT id FROM allergens WHERE code='GLU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000101', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000101', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000102', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000102', (SELECT id FROM allergens WHERE code='HUE'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000102', (SELECT id FROM allergens WHERE code='FRU'), TRUE, TRUE),
    ('77777777-0007-0007-0007-000000000103', (SELECT id FROM allergens WHERE code='LAC'), TRUE, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 13. SUPPLIERS
-- ============================================================================
INSERT INTO suppliers (id, name, contact, phone, email, address) VALUES
    ('88888888-0008-0008-0008-000000000001', 'Distribucions Martí SL',   'Jordi Martí',       '934567890', 'pedidos@marti.cat',  'Carrer de la Indústria, 23, Barcelona'),
    ('88888888-0008-0008-0008-000000000002', 'Peix Fresc del Mediterrà', 'Rosa Calvet',       '935678901', 'rosa@peixfresc.cat', 'Mercat de la Boqueria, Local 45, Barcelona'),
    ('88888888-0008-0008-0008-000000000003', 'Làctics Puigdomènech',     'Marc Puigdomènech', '936789012', 'info@lactics.cat',   'Av. Diagonal, 102, Barcelona')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 14. INGREDIENT SUPPLIERS
-- ============================================================================
INSERT INTO ingredient_suppliers (ingredient_id, supplier_id, establishment_id, unit_cost, is_preferred) VALUES
    ('11111111-0001-0001-0001-000000000001', '88888888-0008-0008-0008-000000000001', '22222222-0002-0002-0002-000000000001', 0.85,  TRUE),
    ('11111111-0001-0001-0001-000000000012', '88888888-0008-0008-0008-000000000002', '22222222-0002-0002-0002-000000000001', 12.50, TRUE),
    ('11111111-0001-0001-0001-000000000003', '88888888-0008-0008-0008-000000000003', '22222222-0002-0002-0002-000000000001', 1.20,  TRUE),
    ('11111111-0001-0001-0001-000000000004', '88888888-0008-0008-0008-000000000003', '22222222-0002-0002-0002-000000000001', 3.50,  TRUE),
    ('11111111-0001-0001-0001-000000000015', '88888888-0008-0008-0008-000000000003', '22222222-0002-0002-0002-000000000001', 18.00, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 15. ESTABLISHMENT INGREDIENTS (stock)
-- ============================================================================
INSERT INTO establishment_ingredients (establishment_id, ingredient_id, current_stock, min_stock, unit) VALUES
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000001', 5.000, 1.000, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000002', 2.000, 0.500, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000003', 4.000, 1.000, 'l'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000004', 1.500, 0.250, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000012', 3.000, 1.000, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000013', 2.000, 0.500, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000014', 4.000, 1.000, 'kg'),
    ('22222222-0002-0002-0002-000000000001', '11111111-0001-0001-0001-000000000015', 0.500, 0.200, 'kg')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 16. MENU CARDS (Originales + Cal Blay)
-- ============================================================================
INSERT INTO menu_cards (id, establishment_id, name, is_public) VALUES
    ('99999999-0009-0009-0009-000000000001', '22222222-0002-0002-0002-000000000001', 'Carta Principal Temporada', TRUE),
    ('99999999-0009-0009-0009-000000000002', '22222222-0002-0002-0002-000000000001', 'Menú del Día',              TRUE),
    ('99999999-0009-0009-0009-000000000003', '22222222-0002-0002-0002-000000000002', 'Carta El Racó',             TRUE),
    ('99999999-0009-0009-0009-000000000004', '22222222-0002-0002-0002-000000000001', 'Gran Carta Cal Blay',       TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 17. MENU CARD ITEMS (Originales + Cal Blay)
-- ============================================================================
INSERT INTO menu_card_items (menu_card_id, recipe_id, price, display_order, is_available) VALUES
    -- Carta Principal (Original)
    ('99999999-0009-0009-0009-000000000001', '77777777-0007-0007-0007-000000000003',  9.50, 1, TRUE),
    ('99999999-0009-0009-0009-000000000001', '77777777-0007-0007-0007-000000000001', 14.50, 2, TRUE),
    ('99999999-0009-0009-0009-000000000001', '77777777-0007-0007-0007-000000000002', 16.00, 3, TRUE),
    ('99999999-0009-0009-0009-000000000001', '77777777-0007-0007-0007-000000000004',  5.50, 4, TRUE),
    
    -- Menú del Día (Original)
    ('99999999-0009-0009-0009-000000000002', '77777777-0007-0007-0007-000000000003',  7.00, 1, TRUE),
    ('99999999-0009-0009-0009-000000000002', '77777777-0007-0007-0007-000000000001', 11.00, 2, TRUE),
    ('99999999-0009-0009-0009-000000000002', '77777777-0007-0007-0007-000000000004',  4.00, 3, TRUE),
    
    -- Carta El Racó (Original)
    ('99999999-0009-0009-0009-000000000003', '77777777-0007-0007-0007-000000000006',  6.50, 1, TRUE),
    ('99999999-0009-0009-0009-000000000003', '77777777-0007-0007-0007-000000000005', 13.00, 2, TRUE),

    -- Carta Cal Blay (Nueva)
    ('99999999-0009-0009-0009-000000000004', '77777777-0007-0007-0007-000000000050', 18.50, 1, TRUE),
    ('99999999-0009-0009-0009-000000000004', '77777777-0007-0007-0007-000000000060', 16.00, 2, TRUE),
    ('99999999-0009-0009-0009-000000000004', '77777777-0007-0007-0007-000000000062', 22.00, 3, TRUE),
    ('99999999-0009-0009-0009-000000000004', '77777777-0007-0007-0007-000000000067', 65.00, 4, TRUE),
    ('99999999-0009-0009-0009-000000000004', '77777777-0007-0007-0007-000000000073',  7.50, 5, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 18. EVENTS
-- ============================================================================
INSERT INTO events (id, establishment_id, room_id, created_by, name, description, event_start, num_guests, status, contact_name, contact_phone, contact_email) VALUES
    ('aaaaaaaa-000a-000a-000a-000000000001', '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000001', '33333333-0003-0003-0003-000000000004', 'Aniversari Família García', 'Celebració aniversari de casament', '2026-05-15 20:00:00+02', 12, 'confirmed', 'Josep García',  '612345678', 'jgarcia@email.com'),
    ('aaaaaaaa-000a-000a-000a-000000000002', '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000002', '33333333-0003-0003-0003-000000000004', 'Dinar Empresa TechCorp',    'Dinar de negocis trimestral',       '2026-05-20 13:00:00+02',  8, 'draft',     'Laura Torres', '698765432', 'ltorres@techcorp.com')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 19. EVENT MENUS
-- ============================================================================
INSERT INTO event_menus (event_id, recipe_id, course_order, is_default) VALUES
    ('aaaaaaaa-000a-000a-000a-000000000001', '77777777-0007-0007-0007-000000000003', 1, TRUE),
    ('aaaaaaaa-000a-000a-000a-000000000001', '77777777-0007-0007-0007-000000000001', 2, TRUE),
    ('aaaaaaaa-000a-000a-000a-000000000001', '77777777-0007-0007-0007-000000000004', 3, TRUE),
    ('aaaaaaaa-000a-000a-000a-000000000002', '77777777-0007-0007-0007-000000000003', 1, TRUE),
    ('aaaaaaaa-000a-000a-000a-000000000002', '77777777-0007-0007-0007-000000000002', 2, TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 20. COMENSALS
-- ============================================================================
INSERT INTO comensals (id, event_id, table_id, seat_id, name, notes, is_active) VALUES
    ('bbbbbbbb-000b-000b-000b-000000000001', 'aaaaaaaa-000a-000a-000a-000000000001', '55555555-0005-0005-0005-000000000003', '66666666-0006-0006-0006-000000000009', 'Josep García',  NULL,                 TRUE),
    ('bbbbbbbb-000b-000b-000b-000000000002', 'aaaaaaaa-000a-000a-000a-000000000001', '55555555-0005-0005-0005-000000000003', '66666666-0006-0006-0006-000000000010', 'Montse García', 'Al·lèrgia al peix',  TRUE),
    ('bbbbbbbb-000b-000b-000b-000000000003', 'aaaaaaaa-000a-000a-000a-000000000001', '55555555-0005-0005-0005-000000000003', '66666666-0006-0006-0006-000000000011', 'Pau García',    'Vegetarià',          TRUE),
    ('bbbbbbbb-000b-000b-000b-000000000004', 'aaaaaaaa-000a-000a-000a-000000000002', '55555555-0005-0005-0005-000000000002', '66666666-0006-0006-0006-000000000005', 'Laura Torres',  NULL,                 TRUE),
    ('bbbbbbbb-000b-000b-000b-000000000005', 'aaaaaaaa-000a-000a-000a-000000000002', '55555555-0005-0005-0005-000000000002', '66666666-0006-0006-0006-000000000006', 'Marc Soler',    'Intolerant lactosa', TRUE)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 21. COMENSAL ALLERGENS
-- ============================================================================
INSERT INTO comensal_allergens (comensal_id, allergen_id, notes) VALUES
    ('bbbbbbbb-000b-000b-000b-000000000002', (SELECT id FROM allergens WHERE code='PES'), 'Al·lèrgia severa, evitar contacte creuament'),
    ('bbbbbbbb-000b-000b-000b-000000000005', (SELECT id FROM allergens WHERE code='LAC'), 'Intolerància, evitar làctics')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 22. ORDERS (Originales + Fake Data de mayo)
-- ============================================================================
INSERT INTO orders (id, establishment_id, room_id, event_id, table_id, waiter_id, created_by, status, created_at) VALUES
    -- Originales activas
    ('cccccccc-000c-000c-000c-000000000001', '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000001', 'aaaaaaaa-000a-000a-000a-000000000001', '55555555-0005-0005-0005-000000000003', '33333333-0003-0003-0003-000000000002', '33333333-0003-0003-0003-000000000002', 'confirmed', NOW()),
    ('cccccccc-000c-000c-000c-000000000002', '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000001', NULL,                                   '55555555-0005-0005-0005-000000000001', '33333333-0003-0003-0003-000000000002', '33333333-0003-0003-0003-000000000002', 'pending', NOW()),
    
    -- Históricas para reporting
    (gen_random_uuid(), '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000001', NULL, '55555555-0005-0005-0005-000000000001', '99999999-9999-9999-9999-000000000003', '99999999-9999-9999-9999-000000000003', 'completed', '2026-05-01 13:30:00+02'),
    (gen_random_uuid(), '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000002', NULL, '55555555-0005-0005-0005-000000000004', '99999999-9999-9999-9999-000000000003', '99999999-9999-9999-9999-000000000003', 'completed', '2026-05-02 21:15:00+02'),
    (gen_random_uuid(), '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000001', NULL, '55555555-0005-0005-0005-000000000002', '99999999-9999-9999-9999-000000000003', '99999999-9999-9999-9999-000000000003', 'completed', '2026-05-05 14:00:00+02'),
    (gen_random_uuid(), '22222222-0002-0002-0002-000000000001', '44444444-0004-0004-0004-000000000002', NULL, '55555555-0005-0005-0005-000000000005', '99999999-9999-9999-9999-000000000003', '99999999-9999-9999-9999-000000000003', 'completed', '2026-05-07 20:45:00+02')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 23. ORDER ITEMS
-- ============================================================================
INSERT INTO order_items (order_id, recipe_id, menu_card_item_id, comensal_id, seat_id, quantity, name, has_allergen_risk, status) VALUES
    (
        'cccccccc-000c-000c-000c-000000000001',
        '77777777-0007-0007-0007-000000000003',
        (SELECT id FROM menu_card_items WHERE menu_card_id='99999999-0009-0009-0009-000000000001' AND recipe_id='77777777-0007-0007-0007-000000000003'),
        'bbbbbbbb-000b-000b-000b-000000000001', '66666666-0006-0006-0006-000000000009',
        1, 'Ensalada César', FALSE, 'confirmed'
    ),
    (
        'cccccccc-000c-000c-000c-000000000001',
        '77777777-0007-0007-0007-000000000002',
        (SELECT id FROM menu_card_items WHERE menu_card_id='99999999-0009-0009-0009-000000000001' AND recipe_id='77777777-0007-0007-0007-000000000002'),
        'bbbbbbbb-000b-000b-000b-000000000001', '66666666-0006-0006-0006-000000000009',
        1, 'Salmón a la plancha', FALSE, 'confirmed'
    ),
    (
        'cccccccc-000c-000c-000c-000000000002',
        '77777777-0007-0007-0007-000000000001',
        NULL,
        NULL, '66666666-0006-0006-0006-000000000001',
        1, 'Lasaña de carne', FALSE, 'pending'
    )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 24. ALLERGEN ALERTS
-- ============================================================================
INSERT INTO allergen_alerts (order_item_id, allergen_id, comensal_id, alert_severity, message, is_resolved)
SELECT
    oi.id,
    (SELECT id FROM allergens WHERE code='PES'),
    'bbbbbbbb-000b-000b-000b-000000000002',
    'high',
    'Comensal Montse García té al·lèrgia severa al peix. Verificar separació a cuina.',
    FALSE
FROM order_items oi
WHERE oi.order_id = 'cccccccc-000c-000c-000c-000000000001'
  AND oi.recipe_id = '77777777-0007-0007-0007-000000000002'
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 25. WAITER ZONES (Objetivo Maig 10 - Filtro de zonas)
-- ============================================================================
INSERT INTO waiter_zones (user_id, room_id, notes) VALUES
    ('33333333-0003-0003-0003-000000000002', '44444444-0004-0004-0004-000000000001', 'Cambrer Principal a la Sala d''Arrossos'),
    ('99999999-9999-9999-9999-000000000003', '44444444-0004-0004-0004-000000000002', 'Test Waiter a la Terrassa')
ON CONFLICT DO NOTHING;