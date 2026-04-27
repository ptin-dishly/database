-- ============================================================================
-- Migration 000010 — event_menus
-- Depends on: 000004 (recipes), 000006 (events)
-- ============================================================================

-- 1. Event menus table (recipes assigned to an event as a planned menu)
CREATE TABLE IF NOT EXISTS event_menus (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id     UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    recipe_id    UUID NOT NULL REFERENCES recipes(id) ON DELETE RESTRICT,
    course_order INTEGER NOT NULL DEFAULT 0,
    is_default   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(event_id, recipe_id)
);
