-- rambler up


alter default privileges revoke execute on functions from public;


grant select on table ph_public.file to ph_anon;
grant insert, delete on table ph_public.file to ph_user;

grant select, insert, update on table ph_public.user to ph_user;

grant select, insert on table ph_public.federated_credential to ph_user;
grant update(
  provider, provider_id, updated_at
) on table ph_public.federated_credential to ph_user;

grant select, insert, delete on table ph_private.session to ph_dev;
grant update(expire, sid, sess) on table ph_private.session to ph_dev;

grant select on table ph_public.property to ph_anon;
grant insert, update on table ph_public.property to ph_user;

grant select on table ph_public.property_media to ph_anon;
grant insert, update, delete on table ph_public.property_media to ph_user;

grant select, insert, delete on table ph_public.saved_property to ph_user;

grant select on table ph_public.property_review to ph_anon;
grant insert, delete, update on table ph_public.property_review to ph_user;

grant select, insert, delete, update on table ph_public.property_report to ph_user;

grant select, insert, update, delete on table ph_public.conversation to ph_user;
grant select, insert, update, delete on table ph_public.message to ph_user;

grant select, insert, update on table ph_public.notification to ph_user;

grant select, insert, update on table ph_public.rental_agreement to ph_user;
grant select, insert, update on table ph_public.property_visit_schedule to ph_user;
grant select, insert on table ph_public.property_payment to ph_user;
grant select, insert, update on table ph_public.membership to ph_user;
grant select, update, delete on table ph_public.pending_property_payment to ph_user;
grant insert, update on table ph_public.pending_property_payment to ph_dev;

grant usage, select on ALL sequences in schema ph_public to ph_user; 


grant execute on function ph_public.current_user() to ph_user;
grant execute on function ph_public.graphql_subscription() to ph_user;
grant execute on function ph_public.broadcast(text, text) to ph_user;
grant execute on function ph_public.search_properties(text, text, text) to ph_anon;


grant execute on function levenshtein(text, text) to ph_anon;
grant execute on function similarity(text, text) to ph_anon;

-- rambler down

revoke execute on function similarity from ph_anon;
revoke execute on function levenshtein(text, text) from ph_anon;
revoke execute on function ph_public.search_properties from ph_anon;
revoke execute on function ph_public.broadcast from ph_user;
revoke execute on function ph_public.graphql_subscription from ph_user;
revoke execute on function ph_public.current_user from ph_user;

revoke usage, select on all sequences in schema ph_public from ph_user;

revoke ALL on ph_public.pending_property_payment from ph_dev;
revoke ALL on ph_public.pending_property_payment from ph_user;
revoke ALL on ph_public.membership from ph_user;
revoke ALL on ph_public.property_payment from ph_user;
revoke ALL on ph_public.property_visit_schedule from ph_user;
revoke ALL on ph_public.rental_agreement from ph_user;
revoke ALL on ph_public.notification from ph_user;
revoke ALL on ph_public.message from ph_user;
revoke ALL on ph_public.conversation from ph_user;
revoke ALL on ph_public.property_report from ph_user;
revoke ALL on ph_public.property_review from ph_user;
revoke ALL on ph_public.saved_property from ph_user;
revoke ALL on ph_public.property_media from ph_anon;
revoke ALL on ph_public.property_media from ph_user;
revoke ALL on ph_public.property from ph_user;
revoke ALL on ph_public.property from ph_anon;
revoke ALL on ph_private.session from ph_dev;
revoke ALL on ph_public.federated_credential from ph_user;
revoke ALL on ph_public.user from ph_user;
revoke ALL on ph_public.file from ph_user;
revoke ALL on ph_public.file from ph_anon;
