-- ============================================================================
-- 28. MASSIVE DEMO SEED FOR MAY 25, 2026
-- ============================================================================
DO $$
DECLARE
    est1_id UUID := '22222222-0002-0002-0002-000000000001';
    est2_id UUID := '22222222-0002-0002-0002-000000000002';
    rm1_id UUID := '44444444-0004-0004-0004-000000000001'; -- Sala Principal
    rm2_id UUID := '44444444-0004-0004-0004-000000000002'; -- Terrassa
    rm3_id UUID := '44444444-0004-0004-0004-000000000003'; -- Sala Única (est2)
    demo_date DATE := '2026-05-25'::DATE;
    
    new_user_id UUID;
    w_id UUID;
    t_id UUID;
    o_id UUID;
    oi_id UUID;
    mci RECORD;
    w_array UUID[];
    t_array UUID[];
    aler_array UUID[];
    aler_id UUID;
    hour_int INT;
    min_int INT;
    creation_time TIMESTAMPTZ;
    rand_status order_status;
    rand_qty INT;
    names1 TEXT[] := ARRAY['Carlos Ruiz', 'Marta Vila', 'Pol Garcia', 'Laura Pons'];
    names2 TEXT[] := ARRAY['David Serra', 'Elena Pou', 'Marc Soler', 'Julia Noguera'];
BEGIN
    -- 1. Insert New Waiters for Est 1 (Ca la Maria)
    FOR i IN 1..4 LOOP
        new_user_id := gen_random_uuid();
        INSERT INTO users (id, establishment_id, email, password_hash, name, role, is_active)
        VALUES (new_user_id, est1_id, 'waiter_extra_'||i||'@calamaria.cat', 'pwd', names1[i], 'waiter', true);
        
        -- Assign to a zone
        INSERT INTO waiter_zones (user_id, room_id)
        VALUES (new_user_id, CASE WHEN i <= 2 THEN rm1_id ELSE rm2_id END);
    END LOOP;
    
    -- 1. Insert New Waiters for Est 2 (El Racó)
    FOR i IN 1..4 LOOP
        new_user_id := gen_random_uuid();
        INSERT INTO users (id, establishment_id, email, password_hash, name, role, is_active)
        VALUES (new_user_id, est2_id, 'waiter_extra_'||i||'@elraco.cat', 'pwd', names2[i], 'waiter', true);
        
        -- Assign to a zone
        INSERT INTO waiter_zones (user_id, room_id)
        VALUES (new_user_id, rm3_id);
    END LOOP;

    -- Fetch allergens
    SELECT array_agg(id) INTO aler_array FROM allergens;

    -- 2. Generate Orders for Est 1
    SELECT array_agg(id) INTO w_array FROM users WHERE establishment_id = est1_id AND role = 'waiter';
    SELECT array_agg(t.id) INTO t_array FROM tables t JOIN rooms r ON t.room_id = r.id WHERE r.establishment_id = est1_id;
    
    FOR i IN 1..70 LOOP
        o_id := gen_random_uuid();
        w_id := w_array[floor(random() * array_length(w_array, 1) + 1)];
        t_id := t_array[floor(random() * array_length(t_array, 1) + 1)];
        
        -- Distribute times: mostly lunch (12-15) and dinner (20-23)
        IF random() < 0.6 THEN
            hour_int := floor(random() * 4) + 12;
        ELSE
            hour_int := floor(random() * 4) + 20;
        END IF;
        min_int := floor(random() * 60);
        creation_time := demo_date + (hour_int || ' hours ' || min_int || ' minutes')::interval;
        
        -- Status distribution: 70% served, 10% cancelled, 10% pending, 5% preparing, 5% confirmed
        rand_status := CASE 
            WHEN random() < 0.7 THEN 'served'::order_status
            WHEN random() < 0.8 THEN 'cancelled'::order_status
            WHEN random() < 0.9 THEN 'pending'::order_status
            WHEN random() < 0.95 THEN 'preparing'::order_status
            ELSE 'confirmed'::order_status
        END;
        
        INSERT INTO orders (id, establishment_id, table_id, waiter_id, status, created_at, updated_at)
        VALUES (o_id, est1_id, t_id, w_id, rand_status, creation_time, creation_time + interval '10 minutes');
        
        -- Add order history
        INSERT INTO order_status_history (order_id, old_status, new_status, changed_at)
        VALUES (o_id, 'pending', rand_status, creation_time + interval '5 minutes');

        -- Order items (3-7 items per order)
        FOR mci IN SELECT m.id, r.id as r_id, r.name FROM menu_card_items m JOIN recipes r ON m.recipe_id = r.id WHERE r.establishment_id = est1_id ORDER BY random() LIMIT (floor(random()*5)+3) LOOP
            oi_id := gen_random_uuid();
            rand_qty := floor(random() * 3) + 1;
            
            INSERT INTO order_items (id, order_id, recipe_id, menu_card_item_id, quantity, name, status, created_at)
            VALUES (oi_id, o_id, mci.r_id, mci.id, rand_qty, mci.name, rand_status, creation_time);
            
            -- Add an allergen alert randomly (8% chance for demo)
            IF random() < 0.08 THEN
                aler_id := aler_array[floor(random() * array_length(aler_array, 1) + 1)];
                INSERT INTO allergen_alerts (order_item_id, allergen_id, alert_severity, message, created_at)
                VALUES (oi_id, aler_id, 'high', 'Alerta: posible alergia detectada por el cliente', creation_time);
            END IF;
        END LOOP;
    END LOOP;

    -- 3. Generate Orders for Est 2
    SELECT array_agg(id) INTO w_array FROM users WHERE establishment_id = est2_id AND role = 'waiter';
    SELECT array_agg(t.id) INTO t_array FROM tables t JOIN rooms r ON t.room_id = r.id WHERE r.establishment_id = est2_id;
    
    FOR i IN 1..50 LOOP
        o_id := gen_random_uuid();
        w_id := w_array[floor(random() * array_length(w_array, 1) + 1)];
        t_id := t_array[floor(random() * array_length(t_array, 1) + 1)];
        
        IF random() < 0.6 THEN
            hour_int := floor(random() * 4) + 13;
        ELSE
            hour_int := floor(random() * 4) + 20;
        END IF;
        min_int := floor(random() * 60);
        creation_time := demo_date + (hour_int || ' hours ' || min_int || ' minutes')::interval;
        
        rand_status := CASE 
            WHEN random() < 0.7 THEN 'served'::order_status
            WHEN random() < 0.8 THEN 'cancelled'::order_status
            WHEN random() < 0.9 THEN 'pending'::order_status
            WHEN random() < 0.95 THEN 'preparing'::order_status
            ELSE 'confirmed'::order_status
        END;
        
        INSERT INTO orders (id, establishment_id, table_id, waiter_id, status, created_at, updated_at)
        VALUES (o_id, est2_id, t_id, w_id, rand_status, creation_time, creation_time + interval '10 minutes');
        
        INSERT INTO order_status_history (order_id, old_status, new_status, changed_at)
        VALUES (o_id, 'pending', rand_status, creation_time + interval '5 minutes');

        FOR mci IN SELECT m.id, r.id as r_id, r.name FROM menu_card_items m JOIN recipes r ON m.recipe_id = r.id WHERE r.establishment_id = est2_id ORDER BY random() LIMIT (floor(random()*5)+3) LOOP
            oi_id := gen_random_uuid();
            rand_qty := floor(random() * 3) + 1;
            
            INSERT INTO order_items (id, order_id, recipe_id, menu_card_item_id, quantity, name, status, created_at)
            VALUES (oi_id, o_id, mci.r_id, mci.id, rand_qty, mci.name, rand_status, creation_time);
            
            IF random() < 0.08 THEN
                aler_id := aler_array[floor(random() * array_length(aler_array, 1) + 1)];
                INSERT INTO allergen_alerts (order_item_id, allergen_id, alert_severity, message, created_at)
                VALUES (oi_id, aler_id, 'high', 'Alerta en sala', creation_time);
            END IF;
        END LOOP;
    END LOOP;
END $$;
