-- 1. Creació del ENUM
CREATE TYPE event_status AS ENUM (
    'draft',
    'confirmed',
    'in_progress',
    'completed',
    'cancelled'
);

-- 2. Taula events
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE RESTRICT,
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR NOT NULL,
    description TEXT,
    event_date DATE NOT NULL,
    event_time TIME,
    num_guests INTEGER NOT NULL DEFAULT 0,
    status event_status NOT NULL DEFAULT 'draft',
    contact_name VARCHAR,
    contact_phone VARCHAR,
    contact_email VARCHAR,
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Índexs
CREATE INDEX IF NOT EXISTS idx_events_establishment ON events(establishment_id);
CREATE INDEX IF NOT EXISTS idx_events_date ON events(event_date);
CREATE INDEX IF NOT EXISTS idx_events_status ON events(status);

-- 3. Taula comensals (Ara amb CASCADE al event_id)
CREATE TABLE IF NOT EXISTS comensals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    table_id UUID REFERENCES tables(id) ON DELETE SET NULL,
    seat_id UUID REFERENCES seats(id) ON DELETE SET NULL,
    name VARCHAR NOT NULL,
    notes TEXT,
    seat_label VARCHAR,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 4. Taula comensal_allergens (Amb CASCADE igual que l'HU de companys)
CREATE TABLE IF NOT EXISTS comensal_allergens (
    comensal_id UUID REFERENCES comensals(id) ON DELETE CASCADE,
    allergen_id UUID REFERENCES allergens(id) ON DELETE CASCADE,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (comensal_id, allergen_id)
);