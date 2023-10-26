import LocalStrategy from "passport-local";
import { login } from "./auth";

module.exports = function (passport) {
  passport.serializeUser((user, cb) => {
    process.nextTick(() => {
      return cb(null, user);
    });
  });
  passport.deserializeUser((user, cb) => {
    process.nextTick(() => cb(null, user));
  });

  passport.use(
    "local-login-phone",
    new LocalStrategy({ usernameField: "phoneNumber" }, login)
  );
};
