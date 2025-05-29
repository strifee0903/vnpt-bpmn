const knex = require("./knex");

async function checkDB() {
    try {
        await knex.raw("SELECT 1");
        console.log("✅ DB connection successful");
    } catch (err) {
        console.error("❌ DB connection failed:", err.message);
        process.exit(1);
    }
}

module.exports = checkDB;
