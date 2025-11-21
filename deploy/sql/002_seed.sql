INSERT INTO puzzles (title, difficulty) VALUES
('Hello MindLab','easy'),
('Tower of Hanoi','hard'),
('Knight''s Tour','medium')
ON CONFLICT DO NOTHING;
