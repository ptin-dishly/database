-- ============================================================================
-- Migration 000015 — Dashboard Analytics Views (DOWN)
-- ============================================================================

REVOKE SELECT ON view_allergens_frequency FROM web_anon;
REVOKE SELECT ON view_staff_performance FROM web_anon;
REVOKE SELECT ON view_tables_size_distribution FROM web_anon;
REVOKE SELECT ON view_tables_status FROM web_anon;
REVOKE SELECT ON view_orders_room_performance FROM web_anon;
REVOKE SELECT ON view_orders_hourly FROM web_anon;
REVOKE SELECT ON view_sales_top_dishes FROM web_anon;
REVOKE SELECT ON view_sales_by_category FROM web_anon;
REVOKE SELECT ON view_sales_by_establishment FROM web_anon;
REVOKE SELECT ON view_sales_weekly_revenue FROM web_anon;

DROP VIEW IF EXISTS view_allergens_frequency;
DROP VIEW IF EXISTS view_staff_performance;
DROP VIEW IF EXISTS view_tables_size_distribution;
DROP VIEW IF EXISTS view_tables_status;
DROP VIEW IF EXISTS view_orders_room_performance;
DROP VIEW IF EXISTS view_orders_hourly;
DROP VIEW IF EXISTS view_sales_top_dishes;
DROP VIEW IF EXISTS view_sales_by_category;
DROP VIEW IF EXISTS view_sales_by_establishment;
DROP VIEW IF EXISTS view_sales_weekly_revenue;
