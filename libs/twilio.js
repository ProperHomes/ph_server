import twilio from "twilio";

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const serviceSid = process.env.TWILIO_VERIFY_SERVICE_SID;

const twilioClient = twilio(accountSid, authToken);

async function checkSmsVerificationToken(phoneNumber, token) {
  const verificationCheck = await twilioClient.verify.v2
    .services(serviceSid)
    .verificationChecks.create({ to: phoneNumber, code: token });
  return verificationCheck.status && verificationCheck.valid;
}

export { twilioClient, checkSmsVerificationToken };
