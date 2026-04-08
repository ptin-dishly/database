CREATE TABLE IF NOT EXISTS refresh_tokens (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE refresh_tokens IS 'Stores one active refresh token per user. Row is upserted on login/refresh and deleted on logout.';
COMMENT ON COLUMN refresh_tokens.user_id IS 'PK and FK to users — guarantees one token per user';
COMMENT ON COLUMN refresh_tokens.token_hash IS 'SHA-256 hash of the refresh token. Never store the raw token.';
COMMENT ON COLUMN refresh_tokens.expires_at IS 'Expiration timestamp. After this, the user must login again.';
