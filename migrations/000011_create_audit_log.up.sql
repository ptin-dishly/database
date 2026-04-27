-- ============================================================================
-- Migration 000011 — audit_log
-- Depends on: 000002 (users)
-- ============================================================================

-- 1. Audit log table (immutable record of all write actions)
CREATE TABLE IF NOT EXISTS audit_log (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID REFERENCES users(id) ON DELETE SET NULL,
    entity_type VARCHAR NOT NULL,
    entity_id   UUID NOT NULL,
    action      VARCHAR NOT NULL,
    before_data JSONB,
    after_data  JSONB,
    ip_address  INET,
    created_at  TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Index for querying by entity
CREATE INDEX IF NOT EXISTS idx_audit_log_entity ON audit_log(entity_type, entity_id);
-- Index for querying by user
CREATE INDEX IF NOT EXISTS idx_audit_log_user ON audit_log(user_id);
-- Index for time-based queries
CREATE INDEX IF NOT EXISTS idx_audit_log_created_at ON audit_log(created_at DESC);
