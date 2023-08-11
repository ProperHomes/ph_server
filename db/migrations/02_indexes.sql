-- rambler up

create index if not exists user_avatar_idx on ph_public.user(avatar_id);
create index if not exists user_cover_image_idx on ph_public.user(cover_image_id);
create index if not exists user_type_idx on ph_public.user(type);
create index if not exists user_org_idx on ph_public.user(org_id);
create index if not exists user_viewed_free_idx on ph_public.user(viewed_free);

create index if not exists org_logo_idx on ph_public.organization(logo_id);


create index if not exists file_creator_idx on ph_public.file(creator_id);
create index if not exists user_federated_cred_idx on ph_public.federated_credential(user_id);


create index if not exists property_owner_idx on ph_public.property(owner_id);
create index if not exists property_agent_idx on ph_public.property(agent_id);
create index if not exists property_tenant_idx on ph_public.property(tenant_id);
create index if not exists property_guest_idx on ph_public.property(guest_id);
create index if not exists property_org_idx on ph_public.property(org_id);
create index if not exists property_type_idx on ph_public.property(type);
create index if not exists property_country_idx on ph_public.property(country);
create index if not exists property_city_idx on ph_public.property(city);
create index if not exists property_is_furnished_idx on ph_public.property(is_furnished);
create index if not exists property_parking_idx on ph_public.property(has_parking);
create index if not exists property_listed_for_idx on ph_public.property(listed_for);
create index if not exists property_condition_idx on ph_public.property(condition);
create index if not exists property_status_idx on ph_public.property(status);
create index if not exists property_slug_idx on ph_public.property(slug);
create index if not exists property_bedrooms_idx on ph_public.property(bedrooms);
create index if not exists property_created_idx on ph_public.property(created_at);


create index if not exists property_media_prop_idx on ph_public.property_media(property_id);
create index if not exists property_media_media_idx on ph_public.property_media(media_id);

create index if not exists property_review_property_idx on ph_public.property_review(property_id);
create index if not exists property_review_user_idx on ph_public.property_review(user_id);

create index if not exists property_report_property_idx on ph_public.property_report(property_id);
create index if not exists property_report_user_idx on ph_public.property_report(user_id);

create index if not exists property_saved_user_idx on ph_public.saved_property(user_id);
create index if not exists property_saved_prop_idx on ph_public.saved_property(property_id);
alter table ph_public.saved_property add constraint saved_property_constraint unique(user_id, property_id); 

create index if not exists notification_by_user_idx on ph_public.notification(by_user_id);
create index if not exists notification_to_user_idx on ph_public.notification(to_user_id);
create index if not exists notification_property_idx on ph_public.notification(property_id);
create index if not exists notification_created_at_idx on ph_public.notification(created_at);
create index if not exists notification_broadcast_idx on ph_public.notification(is_broadcast);

create index if not exists conversation_by_user_idx on ph_public.conversation(by_user_id);
create index if not exists conversation_to_user_idx on ph_public.conversation(to_user_id);
create index if not exists conversation_created_at_idx on ph_public.conversation(created_at);

create index if not exists message_conversation_idx on ph_public.message(conversation_id);
create index if not exists message_by_user_idx on ph_public.message(by_user_id);
create index if not exists message_to_user_idx on ph_public.message(to_user_id);
create index if not exists message_created_at_idx on ph_public.message(created_at);

create index if not exists rental_tenant_idx on ph_public.rental_agreement(tenant_id);
create index if not exists rental_owner_idx on ph_public.rental_agreement(owner_id);
create index if not exists rental_property_idx on ph_public.rental_agreement(property_id);

create index if not exists schedule_tenant_idx on ph_public.property_visit_schedule(tenant_id);
create index if not exists schedule_owner_idx on ph_public.property_visit_schedule(owner_id);
create index if not exists schedule_property_idx on ph_public.property_visit_schedule(property_id);


create index if not exists IDX_session_expire on ph_private.session("expire");


-- gin indexes
create index if not exists property_fts_doc_en_idx on ph_public.property using gin(fts_doc_en);
create index if not exists property_trgm_idx on ph_public.property using gin(title gin_trgm_ops);

-- rambler down

drop index if exists property_trgm_idx;
drop index if exists property_fts_doc_en_idx;

drop index if exists IDX_SESSION_EXPIRE;

drop index if exists schedule_property_idx;
drop index if exists schedule_owner_idx;
drop index if exists schedule_tenant_idx;

drop index if exists rental_property_idx;
drop index if exists rental_owner_idx;
drop index if exists rental_tenant_idx;

drop index if exists message_created_at_idx;
drop index if exists message_to_user_idx;
drop index if exists message_by_user_idx;
drop index if exists message_conversation_idx;

drop index if exists conversation_created_at_idx;
drop index if exists conversation_to_user_idx;
drop index if exists conversation_by_user_idx;

drop index if exists notification_broadcast_idx;
drop index if exists notification_created_at_idx;
drop index if exists notification_property_idx;
drop index if exists notification_to_user_idx;
drop index if exists notification_by_user_idx;

alter table ph_public.saved_property drop constraint saved_property_constraint; 
drop index if exists property_saved_prop_idx;
drop index if exists property_saved_user_idx;

drop index if exists property_report_user_idx;;
drop index if exists property_report_property_idx;

drop index if exists property_review_user_idx;;
drop index if exists property_review_property_idx;

drop index if exists property_media_media_idx;
drop index if exists property_media_prop_idx;

drop index if exists property_created_idx;
drop index if exists property_bedrooms_idx;
drop index if exists property_slug_idx;
drop index if exists property_status_idx;
drop index if exists property_listed_for_idx;
drop index if exists property_parking_idx;
drop index if exists property_is_furnished_idx;
drop index if exists property_city_idx;
drop index if exists property_country_idx;
drop index if exists property_type_idx;
drop index if exists property_org_idx;
drop index if exists property_agent_idx;
drop index if exists property_owner_idx;

drop index if exists user_federated_cred_idx;
drop index if exists file_creator_id;

drop index if exists org_logo_idx;

drop index if exists user_viewed_free_idx;
drop index if exists user_org_idx;
drop index if exists user_type;
drop index if exists user_cover_image_idx;
drop index if exists user_avatar_idx;
