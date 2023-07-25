-- rambler up

alter table ph_public.user enable row level security;
alter table ph_public.federated_credential enable row level security;
alter table ph_public.organization enable row level security;
alter table ph_public.property enable row level security;
alter table ph_public.property_media enable row level security;
alter table ph_public.saved_property enable row level security;
alter table ph_public.notification enable row level security;
alter table ph_public.conversation enable row level security;
alter table ph_public.message enable row level security;

create policy select_user ON ph_public.user for select TO ph_user using (true);
create policy update_user ON ph_public.user for update TO ph_user using (id = current_setting('jwt.claims.user_id', true)::uuid);
create policy insert_user ON ph_public.user for insert TO ph_dev with check (true); -- admin only

create policy select_org ON ph_public.organization for select TO ph_user using (true);
create policy update_org ON ph_public.organization for update TO ph_user using (
    id = current_setting('jwt.claims.user_org_id', true)::uuid and
    (
      current_setting('jwt.claims.org_user_type', true) = 'ADMIN' or
      current_setting('jwt.claims.org_user_type', true) = 'MANAGER'
    ) 
);
create policy insert_org ON ph_public.organization for insert TO ph_dev with check (true); -- admin only


create policy select_property ON ph_public.property for select TO ph_anon using (true);
create policy update_property ON ph_public.property for update TO ph_user using (
  owner_id = current_setting('jwt.claims.user_id', true)::uuid or
  agent_id = current_setting('jwt.claims.user_id', true)::uuid or
  org_id = current_setting('jwt.claims.user_org_id', true)::uuid
);
create policy insert_property ON ph_public.property for insert TO ph_user with check (
  owner_id = current_setting('jwt.claims.user_id', true)::uuid or
  agent_id = current_setting('jwt.claims.user_id', true)::uuid or
  org_id = current_setting('jwt.claims.user_org_id', true)::uuid
);
create policy delete_property ON ph_public.property for delete TO ph_dev using (true); -- admin only



create policy select_property_media ON ph_public.property_media for select TO ph_anon using (true);
create policy insert_property_media ON ph_public.property_media for insert TO ph_user with check (
  exists ( 
    select 1 from ph_public.property as p where ( p.id = ph_public.property_media.property_id ) and 
    (
      p.owner_id = current_setting('jwt.claims.user_id', true)::uuid or
      p.agent_id = current_setting('jwt_claims.user_id', true)::uuid
    ) 
  ) 
);
create policy delete_property_media ON ph_public.property_media for delete TO ph_dev using (true); -- admin only


create policy select_saved_property ON ph_public.saved_property for select TO ph_user using (true);
create policy insert_saved_property ON ph_public.saved_property for insert TO ph_user with check (user_id = current_setting('jwt_claims.user_id', true)::uuid);
create policy delete_saved_property ON ph_public.saved_property for delete TO ph_user using (user_id = current_setting('jwt_claims.user_id', true)::uuid);

create policy select_property_review ON ph_public.property_review for select TO ph_anon using (true);
create policy insert_property_review ON ph_public.property_review for insert TO ph_user with check (user_id = current_setting('jwt_claims.user_id', true)::uuid);
create policy update_property_review ON ph_public.property_review for update TO ph_user using (user_id = current_setting('jwt_claims.user_id', true)::uuid);
create policy delete_property_review ON ph_public.property_review for delete TO ph_user using (user_id = current_setting('jwt_claims.user_id', true)::uuid);

create policy select_notification ON ph_public.notification for select TO ph_user using (true);
create policy update_notification ON ph_public.notification for update TO ph_user using (true);
create policy insert_notification ON ph_public.notification for insert TO ph_user with check (true);

create policy select_conversation ON ph_public.conversation for select TO ph_user using (
  by_user_id = current_setting('jwt_claims.user_id', true)::uuid or
  to_user_id = current_setting('jwt_claims.user_id', true)::uuid
);
create policy insert_conversation ON ph_public.conversation for insert TO ph_user with check (
  by_user_id = current_setting('jwt_claims.user_id', true)::uuid or
  to_user_id = current_setting('jwt_claims.user_id', true)::uuid
);

create policy select_message ON ph_public.message for select TO ph_user using (
  by_user_id = current_setting('jwt_claims.user_id', true)::uuid or
  to_user_id = current_setting('jwt_claims.user_id', true)::uuid
);
create policy insert_message ON ph_public.message for insert TO ph_user with check (
  by_user_id = current_setting('jwt_claims.user_id', true)::uuid
);
create policy update_message ON ph_public.message for update TO ph_user using (
  by_user_id = current_setting('jwt_claims.user_id', true)::uuid
);

-- rambler down


drop policy if exists update_message on ph_public.message;
drop policy if exists insert_message on ph_public.message;
drop policy if exists select_message on ph_public.message;

drop policy if exists insert_conversation on ph_public.conversation;
drop policy if exists select_conversation on ph_public.conversation;

drop policy if exists insert_notification on ph_public.notification;
drop policy if exists update_notification on ph_public.notification;
drop policy if exists select_notification on ph_public.notification;

drop policy if exists delete_property_review on ph_public.property_review;
drop policy if exists update_property_review on ph_public.property_review;
drop policy if exists insert_property_review on ph_public.property_review;
drop policy if exists select_property_review on ph_public.property_review;

drop policy if exists delete_saved_property on ph_public.saved_property;
drop policy if exists insert_saved_property on ph_public.saved_property;
drop policy if exists select_saved_property on ph_public.saved_property;

drop policy if exists delete_property_media on ph_public.property_media;
drop policy if exists insert_property_media on ph_public.property_media;
drop policy if exists select_property_media on ph_public.property_media;

drop policy if exists delete_property on ph_public.property;
drop policy if exists insert_property on ph_public.property;
drop policy if exists update_property on ph_public.property;
drop policy if exists select_property on ph_public.property;

drop policy if exists insert_org on ph_public.organization;
drop policy if exists update_org on ph_public.organization;
drop policy if exists select_org on ph_public.organization;

drop policy if exists insert_user on ph_public.user;
drop policy if exists update_user on ph_public.user;
drop policy if exists select_user on ph_public.user;
