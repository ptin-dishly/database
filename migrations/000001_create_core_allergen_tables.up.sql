CREATE TABLE IF NOT EXISTS allergens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR UNIQUE  NOT NULL,
    name_es VARCHAR NOT NULL,
    name_ca VARCHAR NOT NULL,
    name_en VARCHAR NOT NULL,
    icon_url TEXT,
    description TEXT,
    eu_number INTEGER UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR NOT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);


CREATE TYPE allergen_presence AS ENUM ('contains', 'may_contain', 'traces');

CREATE TABLE IF NOT EXISTS ingredient_allergens (
    ingredient_id UUID REFERENCES ingredients(id) ON DELETE CASCADE,
    allergen_id UUID REFERENCES allergens(id) ON DELETE CASCADE,
    presence allergen_presence NOT NULL DEFAULT 'contains',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (ingredient_id, allergen_id)
);
