-- Create a role for anonymous web requests
CREATE ROLE web_anon NOLOGIN;

-- Grant usage on the public schema to web_anon
GRANT USAGE ON SCHEMA public TO web_anon;

-- Grant select on all current tables in the public schema to web_anon
GRANT SELECT ON ALL TABLES IN SCHEMA public TO web_anon;

-- Grant select on all future tables in the public schema to web_anon
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO web_anon;

-- (Optional) If we want the frontend to be able to insert/update, we would grant it here, 
-- but for a dashboard, read-only is usually sufficient and much safer.
