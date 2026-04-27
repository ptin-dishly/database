-- ============================================================================
-- Migration 000008 — suppliers, ingredient_suppliers
-- Depends on: 000001 (ingredients), 000002 (establishments)
-- ============================================================================

-- 1. Suppliers table
CREATE TABLE IF NOT EXISTS suppliers (
    id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name     VARCHAR NOT NULL,
    contact  VARCHAR,
    phone    VARCHAR,
    email    VARCHAR,
    address  TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 2. Ingredient suppliers table (relationship: which supplier provides which ingredient to which establishment)
CREATE TABLE IF NOT EXISTS ingredient_suppliers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id    UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    supplier_id      UUID NOT NULL REFERENCES suppliers(id) ON DELETE CASCADE,
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    unit_cost        NUMERIC(10, 4),
    is_preferred     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(ingredient_id, supplier_id, establishment_id)
);
