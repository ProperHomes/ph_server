import express from "express";
import cors from "cors";
import helmet from "helmet";
import passport from "passport";
import session from "express-session";
import { graphqlUploadExpress } from "graphql-upload";
import ConnectPgSimple from "connect-pg-simple";

import { pgPool } from "./db/index";
import setupPostgraphileMiddleware from "./libs/postgraphileMiddleware";
import authRoutes from "./routes/auth";
import {
  changePassword,
  forgotPasswordChange,
  revalidateNextJSApp,
  updateUser,
} from "./libs/auth";

const morgan = require("morgan");

const PORT = process.env.PORT || 5000;
const IS_PROD = process.env.NODE_ENV === "production";
const IS_DEV = process.env.NODE_ENV === "development";

const whitelistedOrigins = [
  // "http://localhost:3000",
  "https://staging.properhomes.in",
  "https://www.properhomes.in",
  "https://properhomes.in"
];

const app = express();

app.use(
  cors({
    origin: whitelistedOrigins,
    credentials: true,
  })
);

app.use(helmet());
app.disable("x-powered-by");
app.use(morgan(IS_PROD ? "combined" : "tiny"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(express.text({ type: "application/graphql" }));
app.use(graphqlUploadExpress());

const PgStore = ConnectPgSimple(session);
const sessionStore = new PgStore({
  pool: pgPool,
  schemaName: "ph_private",
  tableName: "session",
});

app.set("trust proxy", 1);
const sessionMiddleware = session({
  rolling: true,
  saveUninitialized: false,
  resave: false,
  cookie: {
    maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    httpOnly: true, // default
    sameSite: "lax", // Cannot be 'strict' otherwise OAuth won't work.
    secure: IS_PROD || IS_DEV,
  },
  store: sessionStore,
  secret: process.env.SESSION_SECRET,
});

const passportInitializeMiddleware = passport.initialize();
const passportSessionMiddleware = passport.session();

app.use(sessionMiddleware);
app.use(passportInitializeMiddleware);
app.use(passportSessionMiddleware);
require("./libs/passportConfig")(passport);

app.set("websocketMiddlewares", [
  sessionMiddleware,
  passportInitializeMiddleware,
  passportSessionMiddleware,
]);

export function getWebsocketMiddlewares() {
  return app.get("websocketMiddlewares");
}

const postgraphileMiddleware = setupPostgraphileMiddleware();
app.set("postgraphileMiddleware", postgraphileMiddleware);
app.use(postgraphileMiddleware);

async function authCheck(req, res, next) {
  if (!req.isAuthenticated() || !req.user) {
    return res.status(401).json({
      authenticated: false,
      message: "user has not been authenticated",
    });
  } else {
    next();
  }
}

app.get("/user", authCheck, (req, res) => {
  const user = req.user;
  if (user) {
    delete user.password_hash;
    return res.status(200).json({
      authenticated: true,
      message: "user successfully authenticated",
      user,
    });
  }
});

app.use("/auth", authRoutes);
app.post("/change/password", authCheck, (req, res) => {
  if (req.user.id === req.body.userId) {
    changePassword(req, res);
  } else {
    return res.status(401).json({
      authenticated: false,
      message: "unautorhized",
    });
  }
});
app.post("/update/user", authCheck, (req, res) => {
  if (req.user.id === req.body.userId) {
    updateUser(req, res);
  } else {
    return res.status(401).json({
      authenticated: false,
      message: "unautorhized",
    });
  }
});

app.post("/change/forgot/password", authCheck, (req, res) => {
  if (req.user.id === req.body.userId) {
    forgotPasswordChange(req, res);
  }
});
app.post("/revalidate", authCheck, (req, res) => {
  revalidateNextJSApp(req, res);
});

app.get("/health", (_req, res) => {
  return res.status(200).json({ success: true });
});

app.listen(PORT, () => {
  console.log(`Server running at port ${PORT} 🚀`);
  if (!IS_PROD) {
    console.log(`GraphiQl running at port ${PORT}/graphiql 🚀`);
  }
});
