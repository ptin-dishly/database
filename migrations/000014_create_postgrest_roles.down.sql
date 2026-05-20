-- Revoke default privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA public REVOKE SELECT ON TABLES FROM web_anon;

-- Revoke select on all tables
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM web_anon;

-- Revoke usage on schema
REVOKE USAGE ON SCHEMA public FROM web_anon;

-- Drop the role
DROP ROLE IF EXISTS web_anon;
