-- rambler up

create trigger new_notification after insert ON ph_public.notification FOR EACH row execute procedure 
    ph_public.graphql_subscription(
        'notificationAdded', -- the "event" string, useful for the client to know what happened
        'graphql:$1', -- the "topic" the event will be published to, as a template
        -- Below if specified, `$1` above will be replaced with NEW.id or OLD.id from the trigger.
        'to_user_id' 
    );

create trigger new_conversation after insert ON ph_public.conversation FOR EACH row execute procedure 
    ph_public.graphql_subscription(
        'conversationStarted', -- the "event" string, useful for the client to know what happened
        'graphql:$1', -- the "topic" the event will be published to, as a template
        -- Below if specified, `$1` above will be replaced with NEW.id or OLD.id from the trigger.
        'to_user_id' 
    );

create trigger new_message after insert ON ph_public.message FOR EACH row execute procedure 
    ph_public.graphql_subscription(
        'newMessageAdded', -- the "event" string, useful for the client to know what happened
        'graphql:$1', -- the "topic" the event will be published to, as a template
        -- Below if specified, `$1` above will be replaced with NEW.id or OLD.id from the trigger.
        'conversation_id' 
    );

-- Todo: add a trigger to delete file from s3 when it is delete in our db.

-- rambler down

drop trigger if exists new_message on ph_public.message;
drop trigger if exists new_conversation on ph_public.conversation;
drop trigger if exists new_notification on ph_public.notification;
