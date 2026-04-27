-- ============================================================================
-- Migration 000007 — rollback
-- ============================================================================

DROP TABLE IF EXISTS allergen_alerts;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TYPE IF EXISTS order_status;
