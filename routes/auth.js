const router = require("express").Router();
const passport = require("passport");

const {
  sendPhoneNumberSmsOTP,
  verifyPhoneNumberOtp,
  verifyPhoneNumberOtpAndLogin,
  signup,
} = require("../libs/auth");

// Todo: very important: either move these to a custom graphql mutations or sanitize the req data; install express-validator ?

router.get("/login/failed", (req, res) => {
  res.status(401).json({
    success: false,
    message: "user failed to authenticate.",
  });
});

router.get("/signup/failed", (req, res) => {
  res.status(500).json({
    success: false,
    message: "failed to signup.",
  });
});

router.get("/forgotpassword/failed", (req, res) => {
  res.status(500).json({
    success: false,
    message: "failed to reset password.",
  });
});

router.post(
  "/login/phone",
  passport.authenticate("local-login-phone", {
    failureRedirect: "/auth/login/failed",
  }),
  (req, res) => {
    if (req.user && req.user.id) {
      return res.status(200).json({ status: "success", userId: req.user.id });
    }
  }
);

router.post(
  "/login/email",
  passport.authenticate("local-login-email", {
    failureRedirect: "/auth/login/failed",
  }),
  (req, res) => {
    if (req.user && req.user.id) {
      return res.status(200).json({ status: "success", userId: req.user.id });
    }
  }
);

router.post(
  "/login/email-link",
  passport.authenticate("magiclink", {
    action: "requestToken",
    failureRedirect: "/auth/login/failed",
    failureMessage: true,
  }),
  (req, res, next) => {
    res.status(200).json({ status: "success" });
  }
);

router.get(
  "/login/email-link/verify",
  passport.authenticate("magiclink", {
    action: "acceptToken",
    successReturnToOrRedirect: process.env.FRONTEND_URL,
    failureRedirect: "/auth/login/failed",
    failureMessage: true,
  })
);

router.post(
  "/forgot/password/email",
  passport.authenticate("magiclink", {
    action: "requestToken",
    failureRedirect: "/auth/forgotpassword/failed",
    failureMessage: true,
  }),
  (req, res, next) => {
    res.status(200).json({ status: "success" });
  }
);

router.get("/forgot/password/email/verify/:username", (req, res, next) => {
  passport.authenticate("magiclink", {
    action: "acceptToken",
    successReturnToOrRedirect: `${process.env.FRONTEND_URL}/settings?forgotPassword=true`,
    failureRedirect: "/auth/forgotpassword/failed",
    failureMessage: true,
  })(req, res, next);
});

router.get("/google/login", passport.authenticate("google-login"));
router.get("/google/redirect/login", (req, res, next) => {
  passport.authenticate("google-login", {
    successRedirect: `${process.env.FRONTEND_URL}/dasboard`,
    failureRedirect: `${process.env.FRONTEND_URL}/login?social_login_failed=true`,
    failureMessage: true,
  })(req, res, next);
});

router.post("/logout", (req, res, next) => {
  req.logout((err) => {
    if (err) {
      next(err);
    } else {
      res.status(200).json({ message: "ok" });
    }
  });
});

router.post("/signup", async (req, res, next) => {
  const { phoneNumber, password, name, type } = req.body;
  if (!phoneNumber || !password || !name || !type) {
    return res
      .status(500)
      .json({ error: "phoneNumber, password, name and type are required" });
  }
  const newUser = await signup(req);
  return req.logIn(newUser, (err) => {
    if (err) {
      return next(err);
    }
    return res.status(200).json({ id: newUser.id });
  });
});

router.post(`/phonenumber/sendotp`, sendPhoneNumberSmsOTP);
router.post("/phonenumber/verifyotp", verifyPhoneNumberOtp);
router.post("/phonenumber/verifyotplogin", verifyPhoneNumberOtpAndLogin);
router.post("/phonenumber/verifyotpforgotpass", verifyPhoneNumberOtpAndLogin);

module.exports = router;
