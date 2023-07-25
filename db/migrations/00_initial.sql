-- rambler up

create schema if not exists ph_public;

-- -- info that require elevated privileges to access
create schema if not exists ph_private;

create extension if not exists "pgcrypto";
comment on extension pgcrypto IS 'cryptographic functions, uuids';

create extension if not exists "citext";
comment on extension citext IS 'data type for case-insensitive character strings';

create extension if not exists "fuzzystrmatch";
create extension if not exists "pg_trgm";

create role ph_anon; -- anynoymous user role who is not authenticated or logged in.
create role ph_user; -- user role who is logged in to our app
create role ph_postgraphile login password 'password'; -- Todo: change password while migrating

grant usage on schema ph_public to ph_anon, ph_user;


grant ph_anon to ph_user;
grant ph_user to ph_postgraphile;
grant ph_postgraphile to ph_dev;

-- rambler down

revoke usage on schema ph_public from ph_anon, ph_user, ph_postgraphile;

drop role if exists ph_postgraphile;
drop role if exists ph_user;
drop role if exists ph_anon;

drop extension if exists "fuzzystrmatch";
drop extension if exists "pg_trgm";

drop schema if exists ph_private;
drop schema if exists ph_public;
