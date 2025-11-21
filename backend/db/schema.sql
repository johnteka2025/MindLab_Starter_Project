create table if not exists users(
  id serial primary key,
  email text unique not null,
  password text not null,
  created_at timestamp default now()
);

create table if not exists attempts(
  id serial primary key,
  user_id int references users(id),
  correct boolean not null,
  created_at timestamp default now()
);

-- Optional view used by earlier scripts; harmless if present
create or replace view v_user_progress as
select
  u.id as u_id,
  count(a.*) filter (where a.correct) as correct_cnt,
  count(a.*) as total_cnt,
  coalesce(round(100.0 * count(a.*) filter (where a.correct) / nullif(count(a.*),0),1),0) as accuracy
from users u
left join attempts a on a.user_id = u.id
group by u.id;
