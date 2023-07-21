import { makeExtendSchemaPlugin, gql, embed } from "graphile-utils";

const getTopicForSubscription = async (args, context, _resolveInfo) => {
  const { id } = args.input;
  if (id && context.pgRole !== "ph_anon") {
    return `graphql:${id}`;
  } else {
    throw new Error("Missing id argument");
  }
};

export const SubscriptionPlugin = makeExtendSchemaPlugin(({ pgSql: sql }) => ({
  typeDefs: gql`
    input SubscriptionInput {
      id: UUID!
    }

    type NotificationSubscriptionPayload {
      event: String
      notification: Notification
    }

    type ConversationSubscriptionPayload {
      event: String
      conversation: Conversation
    }

    type MessageSubscriptionPayload {
      event: String
      message: Message
    }


    extend type Subscription { 
       # input id value should be id of a user for whom the notification is sent to.
       newNotificationAdded(input: SubscriptionInput): NotificationSubscriptionPayload @pgSubscription(topic: ${embed(
         getTopicForSubscription
       )}) 
       
       newConversationAdded(input: SubscriptionInput): ConversationSubscriptionPayload @pgSubscription(topic: ${embed(
         getTopicForSubscription
       )}) 
       
      newMessageAdded(input: SubscriptionInput): MessageSubscriptionPayload @pgSubscription(topic: ${embed(
        getTopicForSubscription
      )}) 
    }
  `,

  resolvers: {
    NotificationSubscriptionPayload: {
      async notification(
        event,
        _args,
        _context,
        { graphile: { selectGraphQLResultFromTable } }
      ) {
        const rows = await selectGraphQLResultFromTable(
          sql.fragment`ph_public.notification`,
          (tableAlias, sqlBuilder) => {
            sqlBuilder.where(
              sql.fragment`${tableAlias}.to_user_id = ${sql.value(
                event.subject
              )}`
            );
            sqlBuilder.orderBy(sql.fragment`created_at`, false);
            sqlBuilder.limit(1);
          }
        );
        return rows[0];
      },
    },

    ConversationSubscriptionPayload: {
      async conversation(
        event,
        _args,
        _context,
        { graphile: { selectGraphQLResultFromTable } }
      ) {
        const rows = await selectGraphQLResultFromTable(
          sql.fragment`ph_public.conversation`,
          (tableAlias, sqlBuilder) => {
            sqlBuilder.where(
              sql.fragment`${tableAlias}.to_user_id = ${sql.value(
                event.subject
              )}`
            );
            sqlBuilder.orderBy(sql.fragment`created_at`, false);
            sqlBuilder.limit(1);
          }
        );
        return rows[0];
      },
    },

    MessageSubscriptionPayload: {
      async message(
        event,
        _args,
        _context,
        { graphile: { selectGraphQLResultFromTable } }
      ) {
        const rows = await selectGraphQLResultFromTable(
          sql.fragment`ph_public.message`,
          (tableAlias, sqlBuilder) => {
            sqlBuilder.where(
              sql.fragment`${tableAlias}.conversation_id = ${sql.value(
                event.subject
              )}`
            );
            sqlBuilder.orderBy(sql.fragment`created_at`, false);
            sqlBuilder.limit(1);
          }
        );
        return rows[0];
      },
    },
  },
}));
