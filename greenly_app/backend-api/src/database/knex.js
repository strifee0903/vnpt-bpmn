const { DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME } = process.env;
module.exports = require("knex")({
    client: "mysql2",
    connection: {
        host: DB_HOST,
        port: DB_PORT,
        user: DB_USER,
        password: DB_PASS,
        database: DB_NAME,
        timezone: '+07:00',
    },
    pool: { min: 0, max: 10 },
});

