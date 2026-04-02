-- Habilitamos pgcrypto para generar los UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS allergens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(10) UNIQUE NOT NULL,
    name_es VARCHAR(100) NOT NULL,
    name_ca VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    icon_url TEXT,
    description TEXT,
    eu_number INTEGER UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
