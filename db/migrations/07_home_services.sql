-- rambler up

ALTER TYPE ph_public.user_type ADD VALUE 'HOME_SERVICE_PROFESSIONAL';

create type ph_public.home_service_status as enum (
    'DRAFT',
    'REJECTED',
    'IN_REVIEW', -- Todo: add this
    'APPROVED'
);

create type ph_public.home_service_category as enum (
    'BATHROOM_CLEANING',
    'KITCHEN_CLEANING',
    'HOME_CLEANING',
    'AC_REPAIR',
    'CAR_WASH', -- Todo: Remove this
    'WOMEN_SALON', -- Todo: REMOVE this
    'MEN_SALON' -- Todo: REMOVE this
);

create table if not exists ph_public.home_service (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text not null,
    price int not null,
    is_active boolean not null,
    image_id uuid references ph_public.file(id),
    professional_id uuid not null references ph_public.user(id),
    status ph_public.home_service_status not null,
    category ph_public.home_service_category not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.home_service_order (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    price int not null,
    service_id uuid not null references ph_public.home_service(id),
    scheduled_at timestamptz not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.home_service_review (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    professional_id uuid not null references ph_public.user(id),
    service_id uuid not null references ph_public.home_service(id),
    rating int not null,
    review text not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);


create index if not exists home_service_prof_idx on ph_public.home_service(professional_id);
create index if not exists home_service_category_idx on ph_public.home_service(category);
create index if not exists home_service_status_idx on ph_public.home_service(status);
create index if not exists home_service_active_idx on ph_public.home_service(is_active);
create index if not exists home_service_created_idx on ph_public.home_service(created_at);

create index if not exists home_service_order_user_idx on ph_public.home_service_order(user_id);
create index if not exists home_service_order_service_idx on ph_public.home_service_order(service_id);
create index if not exists home_service_order_created_idx on ph_public.home_service_order(created_at);

create index if not exists home_service_review_user_idx on ph_public.home_service_review(user_id);
create index if not exists home_service_review_prof_idx on ph_public.home_service_review(professional_id);
create index if not exists home_service_review_service_idx on ph_public.home_service_review(service_id);
create index if not exists home_service_review_created_idx on ph_public.home_service_review(created_at);


grant select on table ph_public.home_service to ph_anon;
grant insert, update on table ph_public.home_service to ph_user;

grant select, insert on table ph_public.home_service_order to ph_user;

grant select on table ph_public.home_service_review to ph_anon;
grant insert, update on table ph_public.home_service_review to ph_user;


ALTER TABLE ph_public.home_service enable row level security;
ALTER TABLE ph_public.home_service_order enable row level security;
ALTER TABLE ph_public.home_service_review enable row level security;

create policy select_home_service ON ph_public.home_service for select TO ph_anon using (true);
create policy update_home_service ON ph_public.home_service for update TO ph_user using (
  professional_id = current_setting('jwt.claims.user_id', true)::uuid or
  exists (select 1 from ph_public.user as u where u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true)
);
create policy insert_home_service ON ph_public.home_service for insert TO ph_user with check (
  professional_id = current_setting('jwt.claims.user_id', true)::uuid or
  exists (select 1 from ph_public.user as u where u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true)
);

create policy select_home_service_order ON ph_public.home_service_order for select TO ph_user using (
  user_id = current_setting('jwt.claims.user_id', true)::uuid or
  exists (select 1 from ph_public.user as u where u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true)
);
create policy update_home_service_order ON ph_public.home_service_order for update TO ph_user using (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);
create policy insert_home_service_order ON ph_public.home_service_order for insert TO ph_user with check (
  user_id = current_setting('jwt.claims.user_id', true)::uuid or
  exists (select 1 from ph_public.user as u where u.id = current_setting('jwt.claims.user_id', true)::uuid and u.is_sys_admin = true)
);


create policy select_home_service_review ON ph_public.home_service_review for select TO ph_anon using (true);
create policy update_home_service_review ON ph_public.home_service_review for update TO ph_user using (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);
create policy insert_home_service_review ON ph_public.home_service_review for insert TO ph_user with check (
  user_id = current_setting('jwt.claims.user_id', true)::uuid
);


-- rambler down

drop policy if exists insert_home_service_review on ph_public.home_service_review;
drop policy if exists update_home_service_review on ph_public.home_service_review;
drop policy if exists select_home_service_review on ph_public.home_service_review;

drop policy if exists insert_home_service_order on ph_public.home_service_order;
drop policy if exists update_home_service_order on ph_public.home_service_order;
drop policy if exists select_home_service_order on ph_public.home_service_order;

drop policy if exists insert_home_service on ph_public.home_service;
drop policy if exists update_home_service on ph_public.home_service;
drop policy if exists select_home_service on ph_public.home_service;

revoke ALL on ph_public.home_service_review from ph_user;
revoke ALL on ph_public.home_service_review from ph_anon;
revoke ALL on ph_public.home_service_order from ph_user;
revoke ALL on ph_public.home_service from ph_user;
revoke ALL on ph_public.home_service from ph_anon;

drop index if exists home_service_review_created_idx;
drop index if exists home_service_review_service_idx;
drop index if exists home_service_review_prof_idx;
drop index if exists home_service_review_user_idx;
drop index if exists home_service_order_created_idx;
drop index if exists home_service_order_service_idx;
drop index if exists home_service_order_user_idx;
drop index if exists home_service_created_idx;
drop index if exists home_service_active_idx;
drop index if exists home_service_status_idx;
drop index if exists home_service_category_idx;
drop index if exists home_service_prof_idx;

drop table if exists ph_public.home_service_review;
drop table if exists ph_public.home_service_order;
drop table if exists ph_public.home_service;
drop type if exists ph_public.home_service_category;
drop type if exists ph_public.home_service_status;
