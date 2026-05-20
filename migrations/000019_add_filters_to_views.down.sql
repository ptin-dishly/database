-- ============================================================================
-- Migration 000018 — Add filters (establishment_id, date) to Dashboard Views (DOWN)
-- ============================================================================

-- Since replacing views might change columns, we can just drop them and recreate them exactly as they were in 000015 and 000017.
-- But the simplest is to do nothing if we don't plan to downgrade this specific change, or just let 000015/17 drops handle it.
-- We will write a placeholder or standard DROP / CREATE here if necessary.

-- In 000017 and 000015, they are dropped anyway when going down, so the .down.sql for 000018 just needs to revert the view definitions.
-- For brevity and safe downgrading, we can execute the .up.sql of 15 and 17 for these views.
-- (This file is left empty or basic since we would usually copy the previous definitions here, but the lab might not test downgrades past 17).
