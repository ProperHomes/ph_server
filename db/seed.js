const bcrypt = require("bcrypt");

const { faker } = require("@faker-js/faker");

const { pgPool } = require("./index");
const dbClient = pgPool;

const propertyTypes = [
  "HOUSE",
  "VILLA",
  "LOT",
  "APARTMENT",
  "BUNGALOW",
  "FARM_HOUSE",
  "PENT_HOUSE",
  "COUNTRY_HOME",
  "CHATEAU",
  "CABIN",
  "PROJECT",
  "COMMERCIAL",
];

const propertyConditions = ["OK", "GOOD", "VERY_GOOD", "AVERAGE"];
const propertyListingType = ["SALE", "RENT", "LEASE"];

const testUserPassword = "prince123#";

async function insertPropertyMedia({ numberOfRecords, propertyId }) {
  console.log("\n Generating fake property media now: ");
  try {
    const insertQuery = `insert into ph_public.property_media(
      property_id, media_url
    ) values ($1, $2)`;
    for (let i = 0; i < numberOfRecords; i++) {
      await dbClient.query(insertQuery, [
        propertyId,
        faker.image.urlLoremFlickr({ category: "building" }),
      ]);
    }
  } catch (err) {
    console.log("error generating properties: ", err);
  }
}

async function insertProperties({ numberOfRecords, ownerId }) {
  console.log("\n Generating fake properties now: ");
  try {
    const insertQuery = `insert into ph_public.property(
      title, type, description, country, city, 
      price, area, sizes, bedrooms, bathrooms, 
      age, has_parking, has_basement, has_swimming_pool,
      is_furnished, owner_id, listed_for, condition, status, slug
    ) values (
      $1, $2, $3, $4, $5, $6, 
      $7, $8, $9, $10, $11, $12, 
      $13, $14, $15, $16, $17, $18, $19, $20
    ) returning *`;

    for (let i = 0; i < numberOfRecords; i++) {
      const propertyType = faker.helpers.arrayElement(propertyTypes);
      const listingType = faker.helpers.arrayElement(propertyListingType);
      const condition = faker.helpers.arrayElement(propertyConditions);
      const city = faker.location.city();
      const title = faker.helpers.fake(
        `A ${condition} ${propertyType} for ${listingType} in the city of ${city} `
      );
      const slug = `${propertyType.toLowerCase()}-for-${listingType.toLowerCase()}-in-${city.toLowerCase()}`;
      const res = await dbClient.query(insertQuery, [
        title,
        propertyType,
        faker.lorem.paragraphs(),
        "India",
        city,
        `${faker.number.int({ max: 10000000 })}`,
        `2 acres`,
        `1500 to 5000 sq.ft`,
        faker.number.int({ max: 6 }),
        faker.number.int({ max: 3 }),
        3,
        true,
        false,
        false,
        true,
        ownerId,
        listingType,
        condition,
        "APPROVED",
        slug,
      ]);
      const newProperty = res.rows[0];
      await insertPropertyMedia({
        numberOfRecords,
        propertyId: newProperty.id,
      });
    }
  } catch (err) {
    console.log("error generating properties: ", err);
  }
}

async function insertSellers({ numberOfRecords }) {
  console.log("\n Generating fake sellers now: ");
  try {
    const insertQuery = `insert into ph_public.user(
        name, phone_number, password_hash, country, city, type
      ) values ($1, $2, $3, $4, $5, $6) returning *`;
    const hashedPassword = await bcrypt.hash(testUserPassword, 10);
    const newUserIds = [];
    for (let i = 0; i < numberOfRecords; i++) {
      const res = await dbClient.query(insertQuery, [
        faker.person.fullName(),
        faker.phone.number("+91##########"),
        hashedPassword,
        "India",
        faker.location.city(),
        "SELLER",
      ]);
      const newUser = res.rows[0];
      newUserIds.push(newUser.id);
      await insertProperties({ numberOfRecords: 5 });
    }
    return newUserIds;
  } catch (err) {
    console.log(err);
  }
}

async function seed() {
  if (process.env.NODE_ENV !== "production") {
    const numberOfRecords =
      process.argv[1] === undefined ? 10 : Number(process.argv[1]);

    try {
      await insertSellers({ numberOfRecords });
    } catch (err) {
      console.log("error generating sellers: ", err);
      return;
    }
    console.log("\n Finished seeding database \n Enjoy:");
    return;
  }
}

module.exports = { seed };
