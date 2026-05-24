-- ============================================================================
-- Migration 000016 — Order Status History and Trigger (DOWN)
-- ============================================================================

REVOKE SELECT ON view_orders_stage_times FROM web_anon;
DROP VIEW IF EXISTS view_orders_stage_times;

DROP TRIGGER IF EXISTS trigger_log_order_status_change ON orders;
DROP FUNCTION IF EXISTS log_order_status_change();

DROP TABLE IF EXISTS order_status_history;
