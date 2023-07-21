const bcrypt = require("bcrypt");

const { faker } = require("@faker-js/faker");

const { pgPool } = require("./index");
const dbClient = pgPool;

const imagesKeys = [
  "test/image_1.jpeg",
  "test/image_2.jpeg",
  "test/image_3.jpeg",
];
const testUserPassword = "prince123#";

const getRandomItem = (items) => {
  return items[Math.floor(Math.random() * items.length)];
};

async function checkAndInsertImages() {
  const fileIds = [];
  const res = await dbClient.query("select id from ph.user where email=$1", [
    "phanindrasrikar@gmail.com",
  ]);
  const fileCreatorId = res.rows[0].id;
  if (fileCreatorId) {
    for (key of imagesKeys) {
      const fileRes = await dbClient.query(
        "select * from ph_public.file where key = $1 and creator_id = $2",
        [key, fileCreatorId]
      );
      if (fileRes?.rowCount === 1) {
        fileIds.push(fileRes.rows[0].id);
      } else {
        const res = await dbClient.query(
          "insert into ph_public.file(key, extension, creator_id) values($1, $2, $3) returning *",
          [key, "image/jpeg", fileCreatorId]
        );
        const newFile = res.rows[0];
        if (newFile) {
          fileIds.push(newFile.id);
        }
      }
    }
  }

  return fileIds;
}

async function seed() {
  if (process.env.NODE_ENV !== "production") {
    const numberOfRecords =
      process.argv[1] === undefined ? 10 : Number(process.argv[1]);

    try {
      await insertUsers({
        numberOfRecords,
      });
    } catch (err) {
      console.log("error generating users: ", err);
      return;
    }
    console.log("\n Finished seeding database \n Enjoy:");
    return;
  }
}

module.exports = { seed };
