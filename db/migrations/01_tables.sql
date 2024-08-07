-- rambler up

create type ph_public.user_type as enum (
    'SELLER',
    'AGENT', -- Todo: remove this
    'BUYER',
    'TENANT',
    'ADMIN'
);

create type ph_public.org_level_type as enum (
    'ADMIN',
    'MANAGER'
);

create type ph_public.property_type as enum (
    'HOUSE',
    'VILLA',
    'LAND',
    'APARTMENT',
    'FLAT',
    'PG',
    'BUNGALOW',
    'FARM_HOUSE',
    'PROJECT', -- Todo: remove this from db
    'COMMERCIAL',
    'HOSTEL',
    'ROOM'
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

create type ph_public.listing_status as enum (
    'DRAFT',
    'IN_REVIEW',
    'REJECTED',
    'APPROVED'
);

create type ph_public.property_status as enum (
    'SOLD',
    'RENTED',
    'LEASED',
    'NOT_FOR_SALE',
    'NOT_FOR_RENT',
    'UNDER_CONSTRUCTION',
    'READY_TO_MOVE'
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


create type ph_public.property_schedule_type as enum (
    'ONLINE',
    'OFFLINE'
);

create type ph_public.payment_mode as enum (
    'UPI',
    'CARD',
    'NETBANKING',
    'CASH'
);

create type ph_public.payment_for as enum (
    'ADVANCE',
    'RENT',
    'SALE',
    'MAINTENANCE',
    'SERVICE'
);

create type ph_public.subscription_type as enum (
    'FREE',
    'PRIME',
    'PREMIUM',
    'CUSTOM',
    'ENTERPRISE'
);

create type ph_public.area_type as enum (
    'CENT',
    'SQ_FT',
    'SQ_MT',
    'SQ_YARD',
    'ACRE',
    'HECTARE',
    'GUNTHA'
);

comment on type ph_public.property_city is E'@enum\n@enumName PropertyCity';
comment on type ph_public.property_status is E'@enum\n@enumName PropertyStatus';
comment on type ph_public.listing_status is E'@enum\n@enumName ListingStatus';
comment on type ph_public.listing_type is E'@enum\n@enumName TypeOfListing';
comment on type ph_public.property_condition is E'@enum\n@enumName PropertyConditionType';
comment on type ph_public.property_type is E'@enum\n@enumName PropertyType';
comment on type ph_public.property_facing is E'@enum\n@enumName PropertyFacing';
comment on type ph_public.user_type is E'@enum\n@enumName TypeOfUser';
comment on type ph_public.property_schedule_type is E'@enum\n@enumName PropertVisitScheduleType'; 
comment on type ph_public.payment_mode is E'@enum\n@enumName PaymentMode';
comment on type ph_public.payment_for is E'@enum\n@enumName PaymentFor';
comment on type ph_public.area_type is E'@enum\n@enumName AreaUnit';
comment on type ph_public.subscription_type is E'@enum\n@enumName SubscriptionType';

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
    name text,
    number serial unique,
    phone_number text unique,
    username text unique,
    email citext unique check(email ~ '[^@]+@[^@]+\.[^@]+'),
    password_hash text,
    type ph_public.user_type not null,
    org_user_type ph_public.org_level_type,
    country text not null,
    city text,
    avatar_id uuid references ph_public.file(id),
    cover_image_id uuid references ph_public.file(id),
    is_sys_admin boolean default false,
    credits int default 1,
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
    pincode int not null,
    price int not null,
    area int not null,
    area_unit ph_public.area_type not null,
    bedrooms int,
    bathrooms int,
    slug text unique,
    age int, -- in years
    has_parking boolean,
    has_basement boolean,
    has_swimming_pool boolean,
    is_furnished boolean, 
    is_semi_furnished boolean,
    facing ph_public.property_facing,
    attributes jsonb default '{}'::jsonb,
    rera_id text,
    owner_id uuid references ph_public.user(id),
    tenant_id uuid references ph_public.user(id),
    guest_id uuid references ph_public.user(id),
    org_id uuid references ph_public.organization(id),
    view_count bigint default 0, -- If property is listed within 24 hours and has more than a set number of views then add a popular/rising
    status ph_public.property_status,
    listing_status ph_public.listing_status not null default 'DRAFT',
    listed_for ph_public.listing_type not null,
    condition ph_public.property_condition not null default 'GOOD',
    in_auction boolean,
    fts_doc_en tsvector not null generated always as (
        to_tsvector('simple', slug)
    ) stored,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_media (
    id uuid primary key default gen_random_uuid(),
    property_id uuid not null references ph_public.property(id) on delete cascade,
    media_id uuid references ph_public.file(id),
    media_url text,
    is_cover_image boolean not null default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_review (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id) on delete cascade,
    property_id uuid not null references ph_public.property(id) on delete cascade,
    content text not null,
    rating int, -- Note: should be between 1 to 5.
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

create table if not exists ph_public.rental_agreement (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references ph_public.user(id),
    owner_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    file_id uuid not null references ph_public.file(id),
    start_date timestamptz not null,
    end_date timestamptz not null, -- note: should be 11 months from start date by default.
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_visit_schedule (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references ph_public.user(id),
    owner_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    scheduled_at timestamptz not null,
    type ph_public.property_schedule_type not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.subscription_purchase (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    amount int not null,
    type ph_public.subscription_type not null default 'FREE',
    next_payment_date timestamptz not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.credits_purchase (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    amount int not null,
    count int not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_credit_expense (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_payment (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    owner_id uuid references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    amount int not null,
    payment_mode ph_public.payment_mode not null,
    payment_for ph_public.payment_for not null,
    transaction_id text not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.pending_property_payment (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    owner_id uuid references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    amount int not null,
    reminder_sent boolean,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);


create table if not exists ph_public.property_insight (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references ph_public.user(id),
    property_id uuid not null references ph_public.property(id),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists ph_public.property_complaint (
    id uuid primary key default gen_random_uuid(),
    tenant_id uuid not null references ph_public.user(id) on delete cascade,
    owner_id uuid not null references ph_public.user(id) on delete cascade,
    property_id uuid not null references ph_public.property(id) on delete cascade,
    complaint text not null,
    resolved boolean default false,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- rambler down
drop table if exists ph_public.property_complaint;
drop table if exists ph_public.property_insight;
drop table if exists ph_public.pending_property_payment;
drop table if exists ph_public.property_payment;
drop table if exists ph_public.property_credit_expense;
drop table if exists ph_public.credits_purchase;
drop table if exists ph_public.subscription_purchase;
drop table if exists ph_public.property_visit_schedule;
drop table if exists ph_public.rental_agreement;
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

drop type if exists ph_public.area_type;
drop type if exists ph_public.subscription_type;
drop type if exists ph_public.payment_for;
drop type if exists ph_public.payment_mode;
drop type if exists ph_public.property_schedule_type;
drop type if exists ph_public.property_city;
drop type if exists ph_public.property_status;
drop type if exists ph_public.listing_status;
drop type if exists ph_public.listing_type;
drop type if exists ph_public.property_facing;
drop type if exists ph_public.property_condition;
drop type if exists ph_public.property_type;
drop type if exists ph_public.org_level_type;
drop type if exists ph_public.user_type;
