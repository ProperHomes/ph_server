-- rambler up

create table if not exists ph_public.builder_employee (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id) on delete cascade,
    builder_id uuid not null references ph_public.builder(id) on delete cascade,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table ph_public.builder_employee add constraint builder_employee_constraint unique(user_id, builder_id); 

create index if not exists builder_employee_user_idx on ph_public.builder_employee(user_id);
create index if not exists builder_employee_builder_idx on ph_public.builder_employee(builder_id);
grant select, insert, delete on table ph_public.builder_employee to ph_user;

create policy select_builder_employee ON ph_public.builder_employee for select TO ph_user using (true);
create policy insert_builder_employee ON ph_public.builder_employee for insert TO ph_user with check (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid or u.is_sys_admin = true
    ) 
);
create policy delete_builder_employee ON ph_public.builder_employee for delete TO ph_user using (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid or u.is_sys_admin = true
    ) 
);


-- rambler down

drop policy if exists delete_builder_employee;
drop policy if exists insert_builder_employee;
drop policy if exists select_builder_employee;
revoke ALL on ph_public.builder_employee from ph_user;
drop index if exists builder_employee_builder_idx;
drop index if exists builder_employee_user_idx;
alter table ph_public.builder_employee drop constraint builder_employee_constraint;
drop table if exists ph_public.builder_employee;
