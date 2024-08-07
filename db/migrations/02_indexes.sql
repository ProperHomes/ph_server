-- rambler up

create index if not exists user_avatar_idx on ph_public.user(avatar_id);
create index if not exists user_cover_image_idx on ph_public.user(cover_image_id);
create index if not exists user_type_idx on ph_public.user(type);
create index if not exists user_org_idx on ph_public.user(org_id);
create index if not exists user_credits_idx on ph_public.user(credits);

create index if not exists org_logo_idx on ph_public.organization(logo_id);


create index if not exists file_creator_idx on ph_public.file(creator_id);
create index if not exists user_federated_cred_idx on ph_public.federated_credential(user_id);


create index if not exists property_owner_idx on ph_public.property(owner_id);
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
create index if not exists property_listing_status_idx on ph_public.property(listing_status);
create index if not exists property_slug_idx on ph_public.property(slug);
create index if not exists property_bedrooms_idx on ph_public.property(bedrooms);
create index if not exists property_created_idx on ph_public.property(created_at);
create index if not exists property_price_idx on ph_public.property(price);


create index if not exists property_media_prop_idx on ph_public.property_media(property_id);
create index if not exists property_media_media_idx on ph_public.property_media(media_id);

create index if not exists property_review_property_idx on ph_public.property_review(property_id);
create index if not exists property_review_user_idx on ph_public.property_review(user_id);
alter table ph_public.property_review add constraint property_review_constraint unique(user_id, property_id); 

create index if not exists property_report_property_idx on ph_public.property_report(property_id);
create index if not exists property_report_user_idx on ph_public.property_report(user_id);

create index if not exists property_saved_user_idx on ph_public.saved_property(user_id);
create index if not exists property_saved_prop_idx on ph_public.saved_property(property_id);
create index if not exists property_saved_created_idx on ph_public.saved_property(created_at);
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
create index if not exists rental_agreement_file_idx on ph_public.rental_agreement(file_id);

create index if not exists schedule_tenant_idx on ph_public.property_visit_schedule(tenant_id);
create index if not exists schedule_owner_idx on ph_public.property_visit_schedule(owner_id);
create index if not exists schedule_property_idx on ph_public.property_visit_schedule(property_id);
create index if not exists schedule_property_type_idx on ph_public.property_visit_schedule(type);
create index if not exists schedule_property_created_idx on ph_public.property_visit_schedule(created_at);

create index if not exists property_payment_user_idx on ph_public.property_payment(user_id);
create index if not exists property_payment_owner_idx on ph_public.property_payment(owner_id);
create index if not exists property_payment_property_idx on ph_public.property_payment(property_id);
create index if not exists property_payment_payment_mode_idx on ph_public.property_payment(payment_mode);
create index if not exists property_payment_payment_for_idx on ph_public.property_payment(payment_for);
create index if not exists property_payment_created_idx on ph_public.property_payment(created_at);
alter table ph_public.property_payment add constraint property_payment_user_unique_constraint unique(user_id, property_id); 

create index if not exists pending_payment_user_idx on ph_public.pending_property_payment(user_id);
create index if not exists pending_payment_owner_idx on ph_public.pending_property_payment(owner_id);
create index if not exists pending_payment_property_idx on ph_public.pending_property_payment(property_id);
create index if not exists pending_payment_created_idx on ph_public.pending_property_payment(created_at);

create index if not exists subscription_purchase_user_idx on ph_public.subscription_purchase(user_id);
create index if not exists subscription_purchase_next_payment_date_idx on ph_public.subscription_purchase(next_payment_date);
create index if not exists subscription_purchase_type_idx on ph_public.subscription_purchase(type);
create index if not exists subscription_purchase_created_at_idx on ph_public.subscription_purchase(created_at);

create index if not exists credits_purchase_user_idx on ph_public.credits_purchase(user_id);

create index if not exists property_credit_expense_user_idx on ph_public.property_credit_expense(user_id);
create index if not exists property_credit_expense_prop_idx on ph_public.property_credit_expense(property_id);
create index if not exists property_credit_expense_created_idx on ph_public.property_credit_expense(created_at);
alter table ph_public.property_credit_expense add constraint property_credit_expense_unique_constraint unique(user_id, property_id);

create index if not exists property_insight_user_idx on ph_public.property_insight(user_id);
create index if not exists property_insight_property_idx on ph_public.property_insight(property_id);
create index if not exists property_insight_created_idx on ph_public.property_insight(created_at);

create index if not exists property_complaint_owner_idx on ph_public.property_complaint(owner_id);
create index if not exists property_complaint_tenant_idx on ph_public.property_complaint(tenant_id);
create index if not exists property_complaint_property_idx on ph_public.property_complaint(property_id);
create index if not exists property_complaint_resolved_idx on ph_public.property_complaint(resolved);
create index if not exists property_complaint_created_idx on ph_public.property_complaint(created_at);

create index if not exists IDX_session_expire on ph_private.session("expire");


-- gin indexes
create index if not exists property_fts_doc_en_idx on ph_public.property using gin(fts_doc_en);
create index if not exists property_trgm_idx on ph_public.property using gin(title gin_trgm_ops);

-- rambler down

drop index if exists property_trgm_idx;
drop index if exists property_fts_doc_en_idx;

drop index if exists IDX_SESSION_EXPIRE;

drop index if exists property_complaint_created_idx;
drop index if exists property_complaint_resolved_idx;
drop index if exists property_complaint_property_idx;
drop index if exists property_complaint_tenant_idx;
drop index if exists property_complaint_owner_idx;

drop index if exists property_insight_created_idx;
drop index if exists property_insight_property_idx;
drop index if exists property_insight_user_idx;

alter table ph_public.property_credit_expense drop constraint property_credit_expense_unique_constraint;
drop index if exists property_credit_expense_created_idx;
drop index if exists property_credit_expense_prop_idx;
drop index if exists property_credit_expense_user_idx;

drop index if exists credits_purchase_user_idx;

drop index if exists subscription_purchase_created_at_idx;
drop index if exists subscription_purchase_type_idx;
drop index if exists subscription_purchsse_next_payment_date_idx;
drop index if exists subscription_user_idx;

drop index if exists pending_payment_created_idx;
drop index if exists pending_payment_property_idx;
drop index if exists pending_payment_owner_idx;
drop index if exists pending_payment_user_idx;

alter table ph_public.property_payment drop constraint property_payment_user_unique_constraint; 
drop index if exists property_payment_created_idx;
drop index if exists property_payment_payment_for_idx;
drop index if exists property_payment_payment_mode_idx;
drop index if exists property_payment_property_idx;
drop index if exists property_payment_owner_idx;
drop index if exists property_payment_user_idx;

drop index if exists schedule_property_created_idx;
drop index if exists schedule_property_type_idx;
drop index if exists schedule_property_idx;
drop index if exists schedule_owner_idx;
drop index if exists schedule_tenant_idx;

drop index if exists rental_agreement_file_idx;
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
drop index if exists property_listing_status_idx;
drop index if exists property_status_idx;
drop index if exists property_condition_idx;
drop index if exists property_listed_for_idx;
drop index if exists property_parking_idx;
drop index if exists property_is_furnished_idx;
drop index if exists property_city_idx;
drop index if exists property_country_idx;
drop index if exists property_type_idx;
drop index if exists property_org_idx;
drop index if exists property_guest_idx;
drop index if exists property_tenant_idx;
drop index if exists property_owner_idx;

drop index if exists user_federated_cred_idx;
drop index if exists file_creator_id;

drop index if exists org_logo_idx;

drop index if exists user_credits_idx;
drop index if exists user_viewed_free_idx; -- Todo: remove this
drop index if exists user_org_idx;
drop index if exists user_type;
drop index if exists user_cover_image_idx;
drop index if exists user_avatar_idx;
