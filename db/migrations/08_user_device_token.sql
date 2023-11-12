-- rambler up

create table if not exists ph_public.user_device_token (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    device_token text not null,
    device_type text not null,
    info jsonb default '{}' :: jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table ph_public.user_device_token add constraint user_device_token_unique_constraint unique(user_id, device_token); 
create index if not exists user_device_token_idx on ph_public.user_device_token(user_id);
grant select, insert, update, delete on ph_public.user_device_token to ph_user;

alter table ph_public.user_device_token enable row level security;

create policy select_user_device_token ON ph_public.user_device_token for select TO ph_user using (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);
create policy insert_user_device_token ON ph_public.user_device_token for insert TO ph_user with check (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);
create policy delete_user_device_token ON ph_public.user_device_token for update TO ph_user using (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);

-- rambler down

drop policy if exists delete_user_device_token on ph_public.user_device_token;
drop policy if exists insert_user_device_token on ph_public.user_device_token;
drop policy if exists select_user_device_token on ph_public.user_device_token;

revoke ALL on ph_public.user_device_token from ph_user;
drop index if exists user_device_token_idx;
alter table ph_public.user_device_token drop constraint user_device_token_unique_constraint; 
drop table if exists ph_public.user_device_token;
