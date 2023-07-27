import LocalStrategy from "passport-local";
import GoogleStrategy from "passport-google-oidc";
import { Strategy as MagicLinkStrategy } from "passport-magic-link";

import { login, verifyProvider, getUserByEmail } from "./auth";
import { sendTransactionalEmail } from "./listmonk";

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

  passport.use(
    "local-login-email",
    new LocalStrategy({ usernameField: "email" }, login)
  );

  passport.use(
    new MagicLinkStrategy(
      {
        secret: process.env.SESSION_SECRET,
        userFields: ["email"],
        tokenField: "token",
        passReqToCallbacks: true,
        verifyUserAfterToken: true,
      },
      async (req, user, token) => {
        const { route } = req;
        let ctaLink, ctaText;
        const userInfo = await getUserByEmail(user.email);
        if (userInfo) {
          if (route.path === "/login/email-link") {
            ctaText = "Verify Email";
            ctaLink = `${process.env.SERVER_URL}/auth/login/email/verify?token=${token}`;
          } else {
            ctaText = "Reset Password";
            ctaLink = `${process.env.SERVER_URL}/auth/forgot/password/email/verify/${userInfo.username}?token=${token}`;
          }
          const data = {
            email: req.body.email,
            templateId: req.body.templateId,
          };
          if (ctaLink) {
            data.data = { ctaLink, ctaText, name: userInfo.name };
          }
          return sendTransactionalEmail(data);
        }
      },
      (_req, user) => {
        return !!user.email;
      }
    )
  );

  passport.use(
    "google-login",
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: "/auth/google/redirect/login",
        scope: ["email", "profile"],
      },
      function verify(issuer, profile, cb) {
        verifyProvider({ issuer, profile, cb });
      }
    )
  );
};
