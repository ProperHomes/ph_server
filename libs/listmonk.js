const axios = require("axios/dist/node/axios.cjs"); // node

async function sendTransactionalEmail(data) {
  if (!data.email || !data.templateId) {
    console.log("both templateId and email should be present");
    return; // Todo: add loggin here
  }
  const { email, templateId } = data;
  try {
    await axios.post(
      `${process.env.LISTMONK_URL}/api/tx`,
      {
        subscriber_email: email,
        data: data.data || {},
        template_id: templateId,
      },
      {
        auth: {
          username: process.env.LISTMONK_USERNAME,
          password: process.env.LISTMONK_PASSWORD,
        },
        headers: { "content-type": "application/json" },
      }
    );
  } catch (err) {
    console.log("Error sending transactional email email:", err);
  }
}

async function subscribeUser(data) {
  const { email, name, listIds, attribs } = data;
  try {
    await axios.post(
      `${process.env.LISTMONK_URL}/api/subscribers`,
      {
        email,
        name,
        status: "enabled",
        lists: listIds || [1], // default list is where every new properhomes user joins in by default
        preconfirm_subscriptions: true,
        attribs: attribs || {},
      },
      {
        auth: {
          username: process.env.LISTMONK_USERNAME,
          password: process.env.LISTMONK_PASSWORD,
        },
        headers: { "content-type": "application/json" },
      }
    );
  } catch (err) {
    console.log("Error subscribing user:", err);
  }
}

module.exports = { subscribeUser, sendTransactionalEmail };
