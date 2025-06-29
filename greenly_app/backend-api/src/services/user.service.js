const knex = require('../database/knex');
const bcrypt = require('bcrypt');
const randomString = require('randomstring');
const ApiError = require('../api-error');
const { unlink } = require('node:fs')

// const ADMIN_TIMEOUT = 15 * 60 * 1000; // 15 phút
const ADMIN_TIMEOUT = 10 * 1000; // 10 giây cho test

// Repository function to abstract the table
function userRepository() {
    return knex('users');
}

function roleRepository() {
    return knex('roles');
}

// Map payload to database schema
function readUser(payload) {
    const user =  {
        u_id: payload.u_id,
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
    // Remove undefined/null values
    Object.keys(user).forEach(key => {
        if (user[key] === undefined || user[key] === null) {
            delete user[key];
        }
    });
    return user;
}

async function checkRole(u_id) {
    try {
        const user = await userRepository()
            .where('u_id', u_id)
            .select('role_id')
            .first();

        if (!user) {
            throw new ApiError(404, 'User not found');
        }

        const role = await roleRepository()
            .where('role_id', user.role_id)
            .first();
        console.log('role: ', role);
        return role ? role.role_id : null;
    } catch (error) {
        console.error('Error checking user role:', error);
        throw error;
    }
};

// Check if email already exists
async function checkExistEmail (email) {
    const user = await userRepository().where({ u_email: email }).first();
    return user;
};


// Register a new user
async function registerUser(payload) {
    const user = readUser(payload);

    // Check if email already exists
    const existingEmail = await checkExistEmail(user.u_email);
    if (existingEmail) {
        throw new Error('This email has been registered with us!');
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

async function login(email, password) {
    const user = await userRepository().where({ u_email: email }).first();
    if (!user) {
        throw new ApiError(404, "You don't have an account yet. Please click register.");
    }

    if (user.is_verified !== 1) {
        throw new ApiError(403, 'Please verify your email to continue.');
    }

    // Compare password using bcrypt with async/await
    let isMatch;
    try {
        isMatch = await bcrypt.compare(password, user.u_pass);
    } catch (error) {
        // Handle bcrypt comparison errors
        throw new ApiError(500, 'Error comparing passwords: ' + error.message);
    }

    // Use if-else to check password match and throw error if it fails
    if (isMatch) {
        await updateLastLogin(user.u_id);
        return {
            u_id: user.u_id,
            u_name: user.u_name,
            u_email: user.u_email,
            role_id: user.role_id,
            u_avt: user.u_avt
        };
    } else {
        throw new ApiError(400, 'Password is incorrect!');
    }
};

// Update last_login for user
async function updateLastLogin(u_id) {
    await userRepository().where({ u_id }).update({
        last_login: knex.fn.now(),
        updated_at: knex.fn.now(),
    });
};

async function checkAdminSessionTimeout(session) {
    if (!session || !session.user) {
        throw new ApiError(401, 'You must log in first.');
    }

    const { u_id, role_id } = session.user;

    if (role_id !== 1) return true; // Không phải admin → bỏ qua

    const now = Date.now();

    // Ưu tiên RAM
    if (session.adminLastActive) {
        const elapsed = now - session.adminLastActive;
        if (elapsed > ADMIN_TIMEOUT) {
            throw new ApiError(440, 'Admin session expired (RAM).');
        }
        session.adminLastActive = now;
        return true;
    }

    // Fallback: check DB
    const user = await userRepository().where({ u_id }).first();

    if (!user || !user.last_login) {
        throw new ApiError(403, 'Invalid login time. Please log in again.');
    }

    const lastLogin = new Date(user.last_login).getTime();
    if (now - lastLogin > ADMIN_TIMEOUT) {
        throw new ApiError(440, 'Admin session expired (DB).');
    }

    session.adminLastActive = now;
    return true;
};

async function getUserById(id) {
    const user = await userRepository()
        .where({ u_id: id })
        .select('*')
        .first();

    if (user) {delete user.u_pass;}

    return user;
};

async function updateUser(id, payload) {
    const existingUser = await userRepository()
        .where({ u_id: id })
        .select('*')
        .first();
    if (!existingUser) {
        return null;
    }

    // Create update object for database
    const update = {
        u_name: payload.u_name,
        u_birthday: payload.u_birthday,
        u_address: payload.u_address,
        u_email: payload.u_email,
        u_avt: payload.u_avt,
        updated_at: knex.fn.now(),
    };

    // Remove undefined/null values
    Object.keys(update).forEach(key => {
        if (update[key] === undefined || update[key] === null) {
            delete update[key];
        }
    });

    if (!update.u_avt) {
        delete update.u_avt;
    }

    // Update database
    await userRepository().where({ u_id: id }).update(update);

    // Handle old avatar deletion
    if (
        payload.u_avt &&
        existingUser.u_avt &&
        payload.u_avt !== existingUser.u_avt &&
        existingUser.u_avt.startsWith('/public/uploads')
    ) {
        unlink(`.${existingUser.u_avt}`, (err) => { });
    }

    // Fetch and return the updated user from database
    const updatedUser = await userRepository()
        .where({ u_id: id })
        .select('*')
        .first();
    if (updatedUser) { delete updatedUser.u_pass; }
    return updatedUser;
};

async function deleteUser(id) {
    const deleteUser = await userRepository()
        .where({ u_id: id })
        .select('u_avt') // Fixed: removed object destructuring
        .first();

    if (!deleteUser) {
        return null;
    }

    await userRepository().where({ u_id: id }).del();

    if (deleteUser.u_avt && deleteUser.u_avt.startsWith('/public/uploads')) {
        unlink(`.${deleteUser.u_avt}`, () => { });
    }

    return deleteUser;
}
module.exports = {
    checkRole,
    registerUser,
    checkExistEmail,
    verifyUserEmail,
    login,
    updateLastLogin,
    checkAdminSessionTimeout,
    getUserById,
    updateUser,
    deleteUser,
};