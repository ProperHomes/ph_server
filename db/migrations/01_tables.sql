-- rambler up

create type ph_public.user_type as enum (
    'SELLER',
    'AGENT',
    'BUYER',
    'BOTH' -- A seller or a buyer account can be converted into BOTH seller & buyer account.
);

create type ph_public.org_level_type as enum (
    'ADMIN',
    'MANAGER'
);

create type ph_public.property_type as enum (
    'HOUSE',
    'VILLA',
    'LOT',
    'APARTMENT',
    'FLAT',
    'PG',
    'BUNGALOW',
    'FARM_HOUSE',
    'PENT_HOUSE',
    'COUNTRY_HOME',
    'CHATEAU',
    'CABIN',
    'PROJECT',
    'COMMERCIAL'
);

create type ph_public.property_condition as enum (
    'OK',
    'GOOD',
    'VERY_GOOD',
    'AVERAGE',
    'BAD'
);

create type ph_public.property_facing as enum (
    'EAST',
    'WEST',
    'NORTH',
    'SOUTH'
);

create type ph_public.listing_type as enum (
    'SALE',
    'RENT',
    'LEASE'
);

create type ph_public.property_status as enum (
    'IN_REVIEW',
    'REJECTED',
    'APPROVED',
    'SOLD',
    'NOT_FOR_SALE',
    'NOT_FOR_RENT'
);

create type ph_public.property_city as enum (
    'AMALAPURAM',
    'BANGALORE',
    'BHIMAVARAM',
    'PALAKOLLU',
    'CHENNAI',
    'DELHI',
    'GURGAON',
    'HYDERABAD',
    'KAKINADA',
    'MUMBAI',
    'PUNE',
    'RAJAHMUNDRY',
    'VIJAYAWADA',
    'VISHAKAPATNAM'
);

comment on type ph_public.property_city is E'@enum\n@enumName PropertyCity';
comment on type ph_public.property_status is E'@enum\n@enumName PropertyStatus';
comment on type ph_public.listing_type is E'@enum\n@enumName TypeOfListing';
comment on type ph_public.property_condition is E'@enum\n@enumName PropertyConditionType';
comment on type ph_public.property_type is E'@enum\n@enumName PropertyType';
comment on type ph_public.property_facing is E'@enum\n@enumName PropertyFacing';
comment on type ph_public.user_type is E'@enum\n@enumName TypeOfUser';

create table if not exists ph_public.file (
    id uuid primary key default gen_random_uuid(),
    key text not null,
    info jsonb default '{}' :: jsonb,
    extension text not null check(char_length(extension) < 20),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.user (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    number serial unique,
    phone_number text unique,
    username text unique,
    email citext unique check(email ~ '[^@]+@[^@]+\.[^@]+'),
    password_hash text,
    type ph_public.user_type not null,
    org_user_type ph_public.org_level_type,
    country text not null,
    city text not null,
    avatar_id uuid references ph_public.file(id),
    cover_image_id uuid references ph_public.file(id),
    attributes jsonb default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

comment on column ph_public.user.password_hash is E'@omit';

alter table ph_public.file add column creator_id uuid not null  references ph_public.user(id);

create table if not exists ph_public.federated_credential (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id) on delete cascade,
    provider varchar(255) not null,
    provider_id varchar(255) not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_private.session (
    "sid" varchar NOT NULL COLLATE "default",
    "sess" json NOT NULL,
    "expire" timestamp(6) NOT NULL
) WITH (OIDS=FALSE);
alter table ph_private.session add constraint "session_pkey" PRIMARY KEY ("sid") NOT DEFERRABLE INITIALLY IMMEDIATE;



create table if not exists ph_public.organization (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    logo_id uuid references ph_public.file(id),
    attributes jsonb default '{}'::jsonb,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
alter table ph_public.user add column org_id uuid references ph_public.organization(id);

create table if not exists ph_public.property (
    id uuid primary key default gen_random_uuid(),
    number serial unique,
    type ph_public.property_type not null,
    title text not null,
    description text not null,
    country text not null,
    city ph_public.property_city not null,
    locality text,
    price text not null,
    area text not null, -- 2 Acres, 2000 sq.ft etc.;
    sizes text not null, -- In Sq.Feet ranges ?
    bedrooms int,
    bathrooms int,
    slug text unique,
    age int, -- in months
    has_parking boolean,
    has_basement boolean,
    has_swimming_pool boolean,
    is_furnished boolean, 
    facing ph_public.property_facing,
    attributes jsonb default '{}'::jsonb,
    owner_id uuid references ph_public.user(id),
    agent_id uuid references ph_public.user(id),
    org_id uuid references ph_public.organization(id),
    status ph_public.property_status not null,
    listed_for ph_public.listing_type not null,
    condition ph_public.property_condition not null default 'GOOD',
    -- Todo: set weights for city and locality
    -- TODO: Include type and listed_for on ts_vector below 
    fts_doc_en tsvector not null generated always as (
        to_tsvector('simple', slug)
    ) stored,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_media (
    id uuid primary key default gen_random_uuid(),
    property_id uuid not null references ph_public.property(id),
    media_id uuid references ph_public.file(id),
    media_url text,
    is_cover_image boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_review (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id) on delete cascade,
    content text not null,
    rating int, -- Note: should be between 1 to 5.
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_reach (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.saved_property (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id) on delete cascade,
    property_id uuid not null references ph_public.property(id) on delete cascade,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_report (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id) on delete cascade,
    report text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.notification (
    id uuid primary key default gen_random_uuid(),
    action_text text, -- eg: commented on your post, raised a toast, followed you etc.;
    by_user_id uuid references ph_public.user(id),
    to_user_id uuid references ph_public.user(id),
    property_id uuid references ph_public.property(id),
    is_broadcast boolean default false,
    broadcast_info jsonb default '{}',
    read_at timestamptz, 
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.conversation (
    id uuid primary key default gen_random_uuid(),
    by_user_id uuid not null references ph_public.user(id),
    to_user_id uuid not null references ph_public.user(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.message (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid not null references ph_public.conversation(id),
    by_user_id uuid not null references ph_public.user(id),
    to_user_id uuid references ph_public.user(id),
    content text not null,
    archived_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);


-- rambler down

drop table if exists ph_public.message;
drop table if exists ph_public.conversation;
drop table if exists ph_public.notification;
drop table if exists ph_public.property_report;
drop table if exists ph_public.saved_property;
drop table if exists ph_public.property_review;
drop table if exists ph_public.property_media;
drop table if exists ph_public.property;
alter table ph_public.user drop column org_id;
drop table if exists ph_public.organization;
drop table if exists ph_private.session;
drop table if exists ph_public.federated_credential;
alter table ph_public.file drop column creator_id;
drop table if exists ph_public.user;
drop table if exists ph_public.file;

drop type if exists ph_public.property_status;
drop type if exists ph_public.listing_type;
drop type if exists ph_public.property_facing;
drop type if exists ph_public.property_condition;
drop type if exists ph_public.property_type;
drop type if exists ph_public.org_level_type;
drop type if exists ph_public.user_type;
