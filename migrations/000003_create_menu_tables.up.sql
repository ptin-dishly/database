-- ============================================================================
-- Migration 000003 — menu_cards, menu_card_items
-- Depends on: 000001 (allergens), 000002 (events, establishments)
-- ============================================================================

-- 1. Taula menu_cards
CREATE TABLE IF NOT EXISTS menu_cards (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE CASCADE,
    name             VARCHAR NOT NULL,
    is_public        BOOLEAN NOT NULL DEFAULT TRUE,
    qr_code_url      TEXT
);

-- 2. Taula menu_card_items
CREATE TABLE IF NOT EXISTS menu_card_items (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    menu_card_id  UUID NOT NULL REFERENCES menu_cards(id) ON DELETE CASCADE,
    recipe_id     UUID NOT NULL REFERENCES recipes(id) ON DELETE RESTRICT,
    price         NUMERIC(8, 2),
    display_order INTEGER NOT NULL DEFAULT 0,
    is_available  BOOLEAN NOT NULL DEFAULT TRUE,

    UNIQUE(menu_card_id, recipe_id)
);