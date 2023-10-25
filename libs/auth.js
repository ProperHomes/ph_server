import bcrypt from "bcrypt";

import { pgPool } from "../db/index";
import { checkSmsVerificationToken, twilioClient } from "./twilio";

const axios = require("axios/dist/node/axios.cjs"); // node

async function signup(req) {
  const { phoneNumber, password, name, type, city, country } = req.body;
  let newUser;
  try {
    const hasedPassword = await bcrypt.hash(password, 10);
    const newRes = await pgPool.query(
      `insert into ph_public.user (password_hash, phone_number, name, type, country, city) values ($1, $2, $3, $4, $5, $6) returning *`,
      [hasedPassword, phoneNumber, name, type, country, city]
    );
    newUser = newRes.rows[0];
  } catch (err) {
    console.log(err);
    return null;
  }
  return newUser;
}

async function login(phoneNumberOrEmail, password, cb) {
  try {
    const userRes = await pgPool.query(
      `select * FROM ph_public.user WHERE phone_number = $1 or email = $1`,
      [phoneNumberOrEmail]
    );
    const user = userRes.rows[0];
    if (!user) {
      return cb(null, false, {
        message: "Account does not exist",
      });
    }
    const isMatched = await bcrypt.compare(password, user.password_hash);
    if (isMatched) {
      return cb(null, user);
    } else {
      return cb(null, false, {
        message: "Incorrect password.",
      });
    }
  } catch (err) {
    cb(err);
  }
}

async function changePassword(req, res) {
  const { userId, oldPass, newPass } = req.body;
  if (!oldPass) {
    return res.status(500).json({ message: `Old password is required` });
  }
  try {
    const userRes = await pgPool.query(
      `select * FROM ph_public.user WHERE id=$1`,
      [userId]
    );
    const user = userRes.rows[0];
    if (!user) {
      return res
        .status(500)
        .json({ message: "Error changing password: no such user" });
    }
    const oldPasswordMatched = await bcrypt.compare(
      oldPass,
      user.password_hash
    );
    if (oldPasswordMatched) {
      const hashedPassword = await bcrypt.hash(newPass, 10);
      await pgPool.query(
        `update ph_public.user set password_hash=$1 where id=$2`,
        [hashedPassword, userId]
      );
      req.user.password_hash = hashedPassword;
      return res.status(200).json({ message: "Password changed succesfully" });
    } else {
      return res.status(500).json({ message: `WRONG Old password` });
    }
  } catch (err) {
    return res.status(500).json({ message: `Error changing password: ${err}` });
  }
}

//IMPORTANT: This should be invoked only after verifying the phone number or email id
async function forgotPasswordChange(req, res) {
  const { userId, newPass } = req.body;
  try {
    const userRes = await pgPool.query(
      `select * FROM ph_public.user WHERE id=$1`,
      [userId]
    );
    const user = userRes.rows[0];
    if (!user) {
      return res
        .status(500)
        .json({ message: "Error changing password: no such user" });
    }
    const hashedPassword = await bcrypt.hash(newPass, 10);
    await pgPool.query(
      `update ph_public.user set password_hash=$1 where id=$2`,
      [hashedPassword, userId]
    );
    req.user.password_hash = hashedPassword;
    return res.status(200).json({ message: "Password changed succesfully" });
  } catch (err) {
    return res.status(500).json({ message: `Error changing password: ${err}` });
  }
}

async function getUserByEmail(email) {
  try {
    const res = await pgPool.query(
      "SELECT * FROM ph_public.user WHERE email = $1",
      [email]
    );
    return res.rows[0];
  } catch (err) {
    console.log(err);
  }
}

async function getUserByPhoneNumber(phoneNumber) {
  try {
    const res = await pgPool.query(
      "SELECT * FROM ph_public.user WHERE phone_number = $1",
      [phoneNumber]
    );
    return res.rows[0];
  } catch (err) {
    console.log(err);
  }
}

async function verifyProvider({ issuer, profile, cb }) {
  let user;
  let userFederatedCredential;
  const { emails, name, id: providerId } = profile;
  const profileEmail = emails[0] && emails[0].value;
  try {
    const credentialRes = await pgPool.query(
      `select * FROM ph_public.federated_credential WHERE provider = $1 and provider_id = $2`,
      [issuer, profile.id]
    );
    userFederatedCredential = credentialRes.rows[0];
  } catch (err) {
    console.log(err);
  }

  if (userFederatedCredential && userFederatedCredential.user_id) {
    try {
      const userRes = await pgPool.query(
        `select * FROM ph_public.user WHERE id = $1 or email=$2`,
        [userFederatedCredential.user_id, profileEmail]
      );
      user = userRes.rows[0];
      if (user) {
        return cb(null, user);
      } else {
        return cb(null, false);
      }
    } catch (err) {
      return cb(err);
    }
  }
  const dbClient = await pgPool.connect();
  try {
    const userRes = await pgPool.query(
      `select * FROM ph_public.user where email = $1`,
      [profileEmail]
    );
    user = userRes.rows[0];
    if (user) {
      await pgPool.query(
        `insert into ph_public.federated_credential(provider, provider_id, user_id) values($1, $2, $3)`,
        [issuer, providerId, user.id]
      );
    } else {
      await dbClient.query("BEGIN");
      const newUserRes = await dbClient.query(
        `insert into ph_public.user(name, email, email_verified) values($1, $2, $3) returning *`,
        [name.givenName, profileEmail, true]
      );
      user = newUserRes.rows[0];
      await dbClient.query(
        `insert into ph_public.federated_credential(provider, provider_id, user_id) values($1, $2, $3)`,
        [issuer, providerId, user.id]
      );
      await dbClient.query("COMMIT");
    }
    return cb(null, user);
  } catch (err) {
    await dbClient.query("ROLLBACK");
    cb(err);
  } finally {
    dbClient.release();
  }
}

async function verifyPhoneNumberOtp(req, res) {
  const { phoneNumber, otp } = req.body;
  if (!phoneNumber || !otp) {
    return res
      .status(500)
      .json({ message: `both Phone number and otp are required: ${err}` });
  }

  try {
    const isValid = await checkSmsVerificationToken(phoneNumber, otp);
    if (isValid) {
      return res.status(200).json({ status: "success: otp value matched" });
    } else {
      return res.status(400).json({ status: "failed: invalid otp value" });
    }
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: err });
  }
}

async function verifyPhoneNumberOtpAndLogin(req, res) {
  const { phoneNumber, otp } = req.body;
  if (!phoneNumber || !otp) {
    return res
      .status(500)
      .json({ message: `both Phone number and otp are required: ${err}` });
  }
  try {
    const isValid = await checkSmsVerificationToken(phoneNumber, otp);
    if (isValid) {
      const phoneNo =
        phoneNumber[0] === "+" ? phoneNumber.slice(1) : phoneNumber;
      const user = await getUserByPhoneNumber(phoneNo);
      return await req.logIn(user, (err) => {
        if (err) {
          return res.status(500).json({
            error: "error after verifyling otp and trying to login user",
          });
        } else {
          return res.status(200).json({ userId: user.id });
        }
      });
    } else {
      return res.status(400).json({ status: "failed: invalid otp value" });
    }
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: err });
  }
}

async function sendPhoneNumberSmsOTP(req, res) {
  const { phoneNumber, isForgotPassword, isSignup } = req.body;
  if (!phoneNumber) {
    return res
      .status(500)
      .json({ message: `Phone number is required: ${err}` });
  }

  let existsAlready = false;
  // Note: if its not forgotpassword then that probably means sign up related so we have to check if already exists or not.
  if (!isForgotPassword && isSignup) {
    try {
      existsAlready = await getUserByPhoneNumber(phoneNumber);
      if (!!existsAlready) {
        return res.status(400).json({
          error: `An account with that phone number already exists`,
        });
      }
    } catch (err) {
      console.log(err);
      return res.status(500).json({ error: err });
    }
  }

  try {
    await twilioClient.verify.v2
      .services(process.env.TWILIO_VERIFY_SERVICE_SID)
      .verifications.create({ to: phoneNumber, channel: "sms" });
    return res.status(200).json({ status: "success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: err });
  }
}

async function revalidateNextJSApp(req, res) {
  if (!req.body.paths) {
    return res.status(500).json({ error: "revalidation paths are required" });
  }
  try {
    await axios.post(
      `${process.env.FRONTEND_URL}/api/revalidate`,
      {
        secret: process.env.FRONTEND_REVALIDATE_SECRET,
        paths: req.body.paths,
      },
      {
        headers: { "content-type": "application/json" },
      }
    );
    return res.status(200).json({ status: "success" });
  } catch (err) {
    return res.status(500).json({ error: "revalidation failed" });
  }
}

export {
  login,
  signup,
  changePassword,
  forgotPasswordChange,
  getUserByEmail,
  getUserByPhoneNumber,
  verifyProvider,
  verifyPhoneNumberOtp,
  sendPhoneNumberSmsOTP,
  verifyPhoneNumberOtpAndLogin,
  revalidateNextJSApp,
};
