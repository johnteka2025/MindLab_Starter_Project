-- Phase 4: dynamic puzzles

CREATE TABLE IF NOT EXISTS users(
  id        SERIAL PRIMARY KEY,
  email     TEXT UNIQUE NOT NULL,
  password  TEXT NOT NULL,
  xp        INT NOT NULL DEFAULT 0,
  level     INT NOT NULL DEFAULT 1,
  streak    INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- requires pgcrypto if you want DB-side UUIDs; we generate UUIDs in Node instead.
CREATE TABLE IF NOT EXISTS dyn_puzzles(
  id         UUID PRIMARY KEY,
  question   TEXT NOT NULL,
  choices    JSONB NOT NULL,
  correct    TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS attempts(
  id         BIGSERIAL PRIMARY KEY,
  user_id    INT REFERENCES users(id) ON DELETE CASCADE,
  puzzle_id  UUID REFERENCES dyn_puzzles(id) ON DELETE CASCADE,
  correct    BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_attempts_user_created ON attempts(user_id, created_at DESC);
