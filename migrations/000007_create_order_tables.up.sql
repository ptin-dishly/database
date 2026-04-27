-- ============================================================================
-- Migration 000007 — orders, order_items
-- Depends on: 000002 (establishments, users), 000004 (recipes),
--             000005 (menu_card_items), 000006 (events, comensals, seats)
-- ============================================================================

-- 1. Order status ENUM
CREATE TYPE order_status AS ENUM (
    'pending',
    'confirmed',
    'preparing',
    'served',
    'cancelled'
);

-- 2. Orders table
CREATE TABLE IF NOT EXISTS orders (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    establishment_id UUID NOT NULL REFERENCES establishments(id) ON DELETE RESTRICT,
    room_id          UUID REFERENCES rooms(id) ON DELETE SET NULL,
    event_id         UUID REFERENCES events(id) ON DELETE SET NULL,
    table_id         UUID REFERENCES tables(id) ON DELETE SET NULL,
    waiter_id        UUID REFERENCES users(id) ON DELETE SET NULL,
    created_by       UUID REFERENCES users(id) ON DELETE SET NULL,
    status           order_status NOT NULL DEFAULT 'pending',
    notes            TEXT,
    created_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Order items table
--    menu_card_item_id nullable:
--      - NULL     → plat sol (à la carte), s'identifica per recipe_id
--      - NOT NULL → plat de carta, referència a menu_card_items
CREATE TABLE IF NOT EXISTS order_items (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id            UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    recipe_id           UUID NOT NULL REFERENCES recipes(id) ON DELETE RESTRICT,
    menu_card_item_id   UUID REFERENCES menu_card_items(id) ON DELETE SET NULL,
    comensal_id         UUID REFERENCES comensals(id) ON DELETE SET NULL,
    seat_id             UUID REFERENCES seats(id) ON DELETE SET NULL,
    quantity            INTEGER NOT NULL DEFAULT 1,
    name                VARCHAR NOT NULL,
    special_notes       TEXT,
    has_allergen_risk   BOOLEAN NOT NULL DEFAULT FALSE,
    status              order_status NOT NULL DEFAULT 'pending',
    created_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT quantity_positive CHECK (quantity > 0)
);

-- 4. Allergen alerts table
CREATE TABLE IF NOT EXISTS allergen_alerts (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_item_id   UUID NOT NULL REFERENCES order_items(id) ON DELETE CASCADE,
    allergen_id     UUID NOT NULL REFERENCES allergens(id) ON DELETE RESTRICT,
    comensal_id     UUID REFERENCES comensals(id) ON DELETE SET NULL,
    alert_severity  VARCHAR NOT NULL,
    message         TEXT,
    is_resolved     BOOLEAN NOT NULL DEFAULT FALSE,
    resolved_by     UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(order_item_id, allergen_id, comensal_id)
);
