-- ============================================================================
-- Migration 000009 — establishment_ingredients (stock)
-- Depends on: 000001 (ingredients), 000002 (establishments)
-- ============================================================================

-- 1. Establishment ingredients table (stock per establishment)
CREATE TABLE IF NOT EXISTS establishment_ingredients (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    ingredient_id    UUID NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
    current_stock    NUMERIC(10, 4) NOT NULL DEFAULT 0,
    min_stock        NUMERIC(10, 4) NOT NULL DEFAULT 0,
    unit             unit_type NOT NULL,
    created_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(establishment_id, ingredient_id),
    CONSTRAINT stock_non_negative CHECK (current_stock >= 0),
    CONSTRAINT min_stock_non_negative CHECK (min_stock >= 0)
);
