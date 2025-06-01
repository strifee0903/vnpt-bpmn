// const knex = require('../database/knex');
// const bcrypt = require('bcrypt');
// const randomString = require('randomstring');

// // Repository function to abstract the table
// function userRepository() {
//     return knex('users');
// }

// function roleRepository() {
//     return knex('roles');
// }

// // Map payload to database schema
// function readUser(payload) {
//     return {
//         u_name: payload.u_name,
//         u_birthday: payload.u_birthday,
//         u_address: payload.u_address,
//         u_email: payload.u_email,
//         u_pass: payload.u_pass,
//         u_avt: payload.u_avt,
//         role_id: payload.role_id || 2,
//         is_verified: payload.is_verified || 0,
//         token: payload.token,
//         created_at: knex.fn.now(),
//         updated_at: knex.fn.now(),
//     };
// }

// // Check if email already exists
// const checkExistEmail = async (email) => {
//     const user = await userRepository().where({ u_email: email }).first();
//     return user;
// };

// // Check if role_id exists
// const checkExistRole = async (role_id) => {
//     const role = await roleRepository().where({ role_id }).first();
//     return role;
// };

// // Register a new user
// async function registerUser(payload) {
//     const user = readUser(payload);

//     // Check if email already exists
//     const existingEmail = await checkExistEmail(user.u_email);
//     if (existingEmail) {
//         throw new Error('This email has been registered with us!');
//     }

//     // Validate role_id
//     const existingRole = await checkExistRole(user.role_id);
//     if (!existingRole) {
//         throw new Error(`Role with ID ${user.role_id} does not exist!`);
//     }

//     // Hash password
//     const saltRounds = 10;
//     user.u_pass = await bcrypt.hash(user.u_pass, saltRounds);

//     // Generate verification token
//     const token = randomString.generate();
//     user.token = token;

//     // Insert user using a transaction
//     return await knex.transaction(async (trx) => {
//         const [u_id] = await trx('users').insert(user);
//         const newUser = await trx('users').where({ u_id }).first();
//         return { message: 'The user has been registered with us!', user: newUser, token };
//     });
// }

// module.exports = {
//     registerUser,
//     checkExistEmail,
// };

const knex = require('../database/knex');
const bcrypt = require('bcrypt');
const randomString = require('randomstring');

// Repository function to abstract the table
function userRepository() {
    return knex('users');
}

function roleRepository() {
    return knex('roles');
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
        token: payload.token,
        created_at: knex.fn.now(),
        updated_at: knex.fn.now(),
    };
}

// Check if email already exists
const checkExistEmail = async (email) => {
    const user = await userRepository().where({ u_email: email }).first();
    return user;
};

// Check if role_id exists
const checkExistRole = async (role_id) => {
    const role = await roleRepository().where({ role_id }).first();
    return role;
};

// Register a new user
async function registerUser(payload) {
    const user = readUser(payload);

    // Check if email already exists
    const existingEmail = await checkExistEmail(user.u_email);
    if (existingEmail) {
        throw new Error('This email has been registered with us!');
    }

    // Validate role_id
    const existingRole = await checkExistRole(user.role_id);
    if (!existingRole) {
        throw new Error(`Role with ID ${user.role_id} does not exist!`);
    }

    // Hash password
    const saltRounds = 10;
    user.u_pass = await bcrypt.hash(user.u_pass, saltRounds);

    // Generate verification token
    const token = randomString.generate();
    user.token = token;

    // Insert user using a transaction
    return await knex.transaction(async (trx) => {
        const [u_id] = await trx('users').insert(user);
        const newUser = await trx('users').where({ u_id }).first();
        return { message: 'The user has been registered with us!', user: newUser, token };
    });
}

// Verify user email by token
async function verifyUserEmail(token) {
    if (!token) {
        throw new Error('No verification token provided');
    }

    const user = await userRepository().where({ token }).first();
    if (!user) {
        throw new Error('Invalid or expired token');
    }

    await userRepository().where({ u_id: user.u_id }).update({
        token: null,
        is_verified: 1,
        updated_at: knex.fn.now(),
    });

    return { message: 'Mail Verified Successfully!' };
}

module.exports = {
    registerUser,
    checkExistEmail,
    verifyUserEmail,
};