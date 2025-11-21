-- Seed a few static puzzles
INSERT INTO puzzles(prompt, options, answer) VALUES
('2 + 2 = ?', ARRAY['3','4','5','22'], '4')
ON CONFLICT DO NOTHING;

INSERT INTO puzzles(prompt, options, answer) VALUES
('Capital of France?', ARRAY['Berlin','Madrid','Paris','Rome'], 'Paris')
ON CONFLICT DO NOTHING;
