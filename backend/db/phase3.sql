-- Phase 3 schema
CREATE TABLE IF NOT EXISTS users(
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL,
  xp INTEGER NOT NULL DEFAULT 0,
  level INTEGER NOT NULL DEFAULT 1,
  streak INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS puzzles(
  id SERIAL PRIMARY KEY,
  prompt TEXT NOT NULL,
  options TEXT[] NOT NULL,
  answer TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS attempts(
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  puzzle_id INTEGER NOT NULL REFERENCES puzzles(id) ON DELETE CASCADE,
  correct BOOLEAN NOT NULL,
  at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM puzzles) THEN
    INSERT INTO puzzles(prompt, options, answer) VALUES
      ('2 + 2 = ?', ARRAY['3','4','5','22'], '4'),
      ('Capital of France?', ARRAY['Berlin','Madrid','Paris','Rome'], 'Paris'),
      ('Color of the sky?', ARRAY['Green','Blue','Red','Brown'], 'Blue');
  END IF;
END$$;
