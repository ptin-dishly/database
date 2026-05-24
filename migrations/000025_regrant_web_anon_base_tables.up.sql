-- Re-grant web_anon access to all base tables.
-- Migration 000014 creates the role and grants it, but if the role was
-- missing when 000014 ran (dirty migration state on VPS), the grants
-- never applied. This migration re-applies them idempotently.

GRANT USAGE ON SCHEMA public TO web_anon;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web_anon;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO web_anon;
