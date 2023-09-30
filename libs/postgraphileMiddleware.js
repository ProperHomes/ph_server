import { postgraphile } from "postgraphile";
import PgPubsub from "@graphile/pg-pubsub";
import { makePluginHook } from "postgraphile";
import { SubscriptionPlugin } from "./graphqlSubscriptionPlugin";
import PgSimplifyInflectorPlugin from "@graphile-contrib/pg-simplify-inflector";
import PostGraphileUploadFieldPlugin from "postgraphile-plugin-upload-field";
import PostGraphileDerivedFieldPlugin from "postgraphile-plugin-derived-field";
import ConnectionFilterPlugin from "postgraphile-plugin-connection-filter";
import PgAggregatesPlugin from "@graphile/pg-aggregates";

import { resolveUpload, resolveSignedUrl } from "./aws.js";
import { pgPool } from "../db/index";
import { getWebsocketMiddlewares } from "../index";

const IS_PROD = process.env.NODE_ENV === "production";

// Todo: Enable Persisted Queries
// https://www.graphile.org/postgraphile/production/#simple-query-allowlist-persisted-queries--persisted-operations

const graphiqlBrandingTweak = {
  ["postgraphile:graphiql:html"](html) {
    return html.replace(
      "</head>",
      '<style type="text/css">div.topBar > div.title > div { visibility: hidden; display: none !important; } div.topBar > div.title::after { content: "Proper Homes" }</style></head>'
    );
  },
};

const setupPostgraphileMiddleware = (app) =>
  postgraphile(pgPool, "ph_public", {
    pluginHook: makePluginHook([PgPubsub, graphiqlBrandingTweak]),
    appendPlugins: [
      SubscriptionPlugin,
      PgSimplifyInflectorPlugin,
      PostGraphileUploadFieldPlugin,
      PostGraphileDerivedFieldPlugin,
      ConnectionFilterPlugin,
      PgAggregatesPlugin,
    ],
    pgSettings: {
      statement_timeout: "5000",
      timezone: "UTC",
    },
    watchPg: !IS_PROD,
    graphiql: !IS_PROD,
    enhanceGraphiql: true,
    subscriptions: true,
    websocketMiddlewares: getWebsocketMiddlewares(),
    additionalGraphQLContextFromRequest: (req, res) => {
      return {
        user: {
          id: req.user && req.user.id,
        },
      };
    },
    dynamicJson: true,
    setofFunctionsContainNulls: false,
    ignoreRBAC: false,
    ignoreIndexes: false,
    // retryOnInitFail: true
    showErrorStack: true,
    extendedErrors: IS_PROD ? ["errcode"] : ["hint", "detail", "errcode"],
    allowExplain: true,
    legacyRelations: "omit",
    sortExport: true,
    enableQueryBatching: true,
    disableQueryLog: IS_PROD,
    pgStrictFunctions: true,
    graphileBuildOptions: {
      connectionFilterOperatorNames: {
        isNull: "null",
        equalTo: "eq",
        notEqualTo: "ne",
        lessThan: "lt",
        lessThanOrEqualTo: "lte",
        greaterThan: "gt",
        greaterThanOrEqualTo: "gte",
      },
      connectionFilterRelations: true,
      connectionFilterComputedColumns: false,
      connectionFilterSetofFunctions: false,
      connectionFilterArrays: false,
      connectionFilterAllowNullInput: true,
      connectionFilterAllowEmptyObjectInput: true,
      uploadFieldDefinitions: [
        {
          match: ({ column, table }) => {
            return column === "key";
          },
          resolve: resolveUpload,
        },
      ],
      derivedFieldDefinitions: [
        {
          identifiers: ["ph_public.file.key"],
          inflect: () => `signedUrl`,
          resolve: resolveSignedUrl,
        },
      ],
    },
    pgSettings: (req) => {
      const { FRONTEND_URL, AUTHORIZATION_SECRET } = process.env;
      const entity = req.user;
      const { origin, authorization } = req.headers;
      if (req.isAuthenticated() && entity) {
        return {
          role: "ph_user",
          "jwt.claims.user_id": `${entity.id}`,
        };
      }
      const isFromAllowedHost = FRONTEND_URL === origin;
      const isAnonAllowed = `Bearer ${AUTHORIZATION_SECRET}` === authorization;
      if (isFromAllowedHost || isAnonAllowed) {
        return {
          role: "ph_anon",
        };
      } else {
        return {
          role: "NOT_AUTHORIZED",
        };
      }
    },
  });

export default setupPostgraphileMiddleware;
