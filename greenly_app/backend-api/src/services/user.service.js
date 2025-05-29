const knex = require('../database/knex');
const bcrypt = require('bcrypt');

// Repository function to abstract the table
function userRepository() {
    return knex('users');
}

// Map payload to database schema
function readUser(payload) {
    return {
        u_name: payload.u_name,
        u_birthday: payload.u_birthday,
        u_address: payload.u_address,
        u_email: payload.u_email,
        u_pass: payload.u_pass,
        u_avt: payload.u_avt,
        role_id: payload.role_id || 2,
        is_verified: payload.is_verified || 0,
        created_at: knex.fn.now(),
        updated_at: knex.fn.now(),
    };
}

// Check if email already exists
const checkExistEmail = async (email) => {
    const user = await userRepository().where({ u_email: email }).first();
    return user;
};

// Register a new user
async function registerUser(payload) {
    const user = readUser(payload);

    // Check if email already exists
    const existingEmail = await checkExistEmail(user.u_email);
    if (existingEmail) {
        throw new Error('Email already exists!');
    }

    // Hash password
    const saltRounds = 10;
    user.u_pass = await bcrypt.hash(user.u_pass, saltRounds);

    // Insert user using a transaction
    return await knex.transaction(async (trx) => {
        const [u_id] = await trx('users').insert(user);
        const newUser = await trx('users').where({ u_id }).first();
        return { message: 'The user has been registered with us!', user: newUser };
    });
}

module.exports = { 
    registerUser, 
    checkExistEmail,
};