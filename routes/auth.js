const router = require("express").Router();
const passport = require("passport");

const {
  sendPhoneNumberSmsOTP,
  verifyPhoneNumberOtp,
  verifyPhoneNumberOtpAndLogin,
  signup,
} = require("../libs/auth");

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
