-- rambler up

--- builders
alter table ph_public.builder add column is_active boolean default false;
create index if not exists builder_active on ph_public.builder(is_active);
create policy insert_builder_user ON ph_public.builder for insert TO ph_user with check (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid
    ) 
);
create policy delete_builder on ph_public.builder for delete to ph_dev using (
   exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);

--- projects
alter table ph_public.project add column is_active boolean default false;
create index if not exists project_active on ph_public.project(is_active);
create policy insert_project_user ON ph_public.project for insert TO ph_user with check (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid
    ) 
);
create policy delete_project on ph_public.project for delete to ph_dev using (
   exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);



-- rambler down

drop policy if exists delete_project on ph_public.project;
drop policy if exists insert_project_user on ph_public.project;
drop index if exists project_active;
alter table ph_public.project drop column is_active;

drop policy if exists delete_builder on ph_public.builder;
drop policy if exists insert_builder_user on ph_public.builder;
drop index if exists builder_active;
alter table ph_public.builder drop column is_active;
