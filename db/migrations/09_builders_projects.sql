-- rambler up

create type ph_public.project_status as enum (
    'UNDER_CONSTRUCTION',
    'READY_TO_MOVE',
    'SOLD_OUT'
);

create table if not exists ph_public.builder (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    name text not null,
    description text not null,
    logo_id uuid references ph_public.file(id),
    cover_image_id uuid references ph_public.file(id),
    experience int,
    office_address text,
    operating_cities text[],
    phone_number text, 
    attributes jsonb default '{}' :: jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.project (
    id uuid primary key default gen_random_uuid(),
    slug text not null unique,
    builder_id uuid not null references ph_public.builder(id),
    name text not null,
    description text not null,
    is_rera_approved boolean not null,
    logo_id uuid references ph_public.file(id),
    cover_image_id uuid references ph_public.file(id),
    brochure_id uuid references ph_public.file(id),
    address text,
    pincode text,
    status ph_public.project_status not null,
    price_range int[],
    amenities jsonb default '{}' :: jsonb,
    attributes jsonb default '{}' :: jsonb,
    launch_date timestamptz,
    completed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table ph_public.property add column project_id uuid references ph_public.project(id);

create table if not exists ph_public.project_media (
    id uuid primary key default gen_random_uuid(),
    project_id uuid not null references ph_public.project(id) on delete cascade,
    media_id uuid references ph_public.file(id),
    media_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);


create index if not exists property_project_idx on ph_public.property(project_id);

create index if not exists project_media_project_idx on ph_public.project_media(project_id);
create index if not exists project_media_media_idx on ph_public.project_media(media_id);

create index if not exists builder_logo_idx on ph_public.builder(logo_id);
create index if not exists builder_cover_idx on ph_public.builder(cover_image_id);

create index if not exists project_builder_idx on ph_public.project(builder_id);
create index if not exists project_logo_idx on ph_public.project(logo_id);
create index if not exists project_cover_idx on ph_public.project(cover_image_id);
create index if not exists project_brochure_idx on ph_public.project(brochure_id);


grant select on ph_public.builder to ph_anon;
grant insert, update on ph_public.builder to ph_user;
grant delete on ph_public.builder to ph_dev;

grant select on ph_public.project to ph_anon;
grant insert, update on ph_public.project to ph_user;
grant delete on ph_public.project to ph_dev;

create policy select_builder ON ph_public.builder for select TO ph_anon using (true);
create policy update_builder ON ph_public.builder for update TO ph_user using (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);
create policy insert_builder ON ph_public.builder for insert TO ph_user with check (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);


create policy select_project ON ph_public.project for select TO ph_anon using (true);
create policy update_project ON ph_public.project for update TO ph_user using (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);
create policy insert_project ON ph_public.project for insert TO ph_user with check (
    exists (
      select 1 from ph_public.user as u where 
      u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true
    ) 
);



-- rambler down

drop policy if exists insert_project on ph_public.project;
drop policy if exists update_project on ph_public.project;
drop policy if exists select_project on ph_public.project;

drop policy if exists insert_builder on ph_public.builder;
drop policy if exists update_builder on ph_public.builder;
drop policy if exists select_builder on ph_public.builder;

revoke ALL on ph_public.project from ph_dev;
revoke ALL on ph_public.project from ph_user;
revoke ALL on ph_public.project from ph_anon;

revoke ALL on ph_public.builder from ph_dev;
revoke ALL on ph_public.builder from ph_user;
revoke ALL on ph_public.builder from ph_anon;

drop index if exists project_brochure_idx;
drop index if exists project_cover_idx;
drop index if exists project_logo_idx;
drop index if exists project_builder_idx;

drop index if exists builder_cover_idx;
drop index if exists builder_logo_idx;

drop index if exists project_media_media_idx;
drop index if exists project_media_project_idx;

drop index if exists property_project_idx;

drop table if exists ph_public.project_media;

alter table ph_public.property drop column project_id;

drop table if exists ph_public.project;
drop table if exists ph_public.builder;

drop type if exists ph_public.project_status;
