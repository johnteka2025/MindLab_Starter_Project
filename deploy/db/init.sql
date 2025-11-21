create table if not exists puzzles (
  id serial primary key,
  title text not null,
  prompt text not null,
  difficulty text not null
);

insert into puzzles (title, prompt, difficulty) values
  ('Puzzle #1', 'Arrange the numbers so they sum to 15.', 'easy'),
  ('Puzzle #2', 'Place the queens so none attack another.', 'medium'),
  ('Puzzle #3', 'Find the shortest path visiting all nodes.', 'hard')
on conflict do nothing;
