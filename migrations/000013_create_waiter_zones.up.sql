CREATE TABLE IF NOT EXISTS waiter_zones (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    room_id           UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    assignment_date   DATE DEFAULT CURRENT_DATE,
    notes             TEXT,
    created_at        TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, room_id, assignment_date)
);