require("dotenv").config();
const { Pool } = require("pg");

const pgPool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

module.exports = { pgPool };
