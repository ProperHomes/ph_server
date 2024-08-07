-- rambler up


-- user who is logged in and sending the current request
create function ph_public.current_user() returns json as $$
    select row_to_json(ph_public.user.*) from ph_public.user where id = current_setting('jwt.claims.user_id', true)::uuid limit 1
$$ language sql stable;


-- credit: https://www.graphile.org/postgraphile/subscriptions/
create function ph_public.graphql_subscription() returns trigger as $$
declare
  v_process_new bool = (TG_OP = 'INSERT' OR TG_OP = 'UPDATE');
  v_process_old bool = (TG_OP = 'UPDATE' OR TG_OP = 'DELETE');
  v_event text = TG_ARGV[0];
  v_topic_template text = TG_ARGV[1];
  v_attribute text = TG_ARGV[2];
  v_record record;
  v_sub text;
  v_topic text;
  v_i int = 0;
  v_last_topic text;
begin
  -- On UPDATE sometimes topic may be changed for NEW record,
  -- so we need notify to both topics NEW and OLD.
  for v_i in 0..1 loop
    
    if (v_i = 0) and v_process_new is true then
      v_record = new;
    elsif (v_i = 1) and v_process_old is true then
      v_record = old;
    else
      continue;
    end if;
    
    if v_attribute is not null then
      execute 'select $1.' || quote_ident(v_attribute)
        using v_record
        into v_sub;
    end if;
    
    if v_sub is not null then
      v_topic = replace(v_topic_template, '$1', v_sub);
    else
      v_topic = v_topic_template;
    end if;

    if v_topic is distinct from v_last_topic then
      -- This if statement prevents us from triggering the same notification twice
      v_last_topic = v_topic;
      perform pg_notify(v_topic, json_build_object(
        'event', v_event,
        'subject', v_sub
      )::text);
    end if;

  end loop;
  return v_record;
end;
$$ language plpgsql volatile set search_path from current;


create function ph_public.broadcast(topic_name text, payload text) returns text as $$
begin
      perform pg_notify(topic_name, json_build_object('event', topic_name, 'result', payload)::text); 
      return payload;
end;
$$ language plpgsql VOLATILE STRICT;

create function ph_public.search_properties(search_text text, city_name text, locality_name text, bedrooms_count int, listing_type text) 
returns setof ph_public.property as $$
begin
  if search_text is not null then
    return query select * from ph_public.property p where
      case when city_name is not null then p.city::text = city_name else true end 
      and 
      case when locality is not null then similarity(p.locality, locality_name) > 0.3 else true end 
      and
      case when listing_type is not null then p.listed_for::text = listing_type else true end 
      and
      case when bedrooms_count is not null then p.bedrooms = bedrooms_count else true end 
      and
      (
        similarity(p.title, search_text) > 0.2 or 
        similarity(p.type::text, search_text) > 0.2 or 
        p.fts_doc_en @@ to_tsquery('simple', search_text)
      );
  end if;
end;
$$ language plpgsql stable;


create function ph_public.search_own_properties(search_text text, city text, locality text, owner_id uuid) 
returns setof ph_public.property as $$
  select * from ph_public.property p where p.owner_id = owner_id and 
   ((similarity(p.title, search_text) > 0.2 or similarity(p.city::text, search_text) > 0.2) or p.fts_doc_en @@ to_tsquery('simple', search_text))
$$ language sql stable;

-- rambler down

drop function if exists ph_public.search_own_properties;
drop function if exists ph_public.search_properties;

drop function if exists ph_public.broadcast;
drop function if exists ph_public.graphql_subscription;
drop function if exists ph_public.current_user cascade;
