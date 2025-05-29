const usersService = require('../services/user.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');
const { validationResult } = require('express-validator');

async function register(req, res, next) {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return next(new ApiError(400, 'Validation failed', { errors: errors.array() }));
    }

    // Validate required fields
    if (!req.body.u_name || !req.body.u_address || !req.body.u_email || !req.body.u_pass) {
        return next(new ApiError(400, 'Invalid data'));
    }
    if (isNaN(new Date(req.body.u_birthday))) {
        return next(new ApiError(400, 'Date of birth is not a valid date!'));
    }
    if (typeof req.body.u_email !== 'string' || !/\S+@\S+\.\S+/.test(req.body.u_email)) {
        return next(new ApiError(400, 'Email is not in correct format!'));
    }
    if (typeof req.body.u_address !== 'string') {
        return next(new ApiError(400, 'Address must be a string!'));
    }
    if (req.body.u_pass.length < 8) {
        return next(new ApiError(400, 'Password must be at least 8 characters!'));
    }

    try {
        const userData = {
            u_name: req.body.u_name,
            u_birthday: req.body.u_birthday,
            u_address: req.body.u_address,
            u_email: req.body.u_email,
            u_pass: req.body.u_pass,
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : null,
        };
        const result = await usersService.registerUser(userData);
        return res
            .status(201)
            .set({ Location: `${req.baseUrl}/${result.user.u_id}` })
            .json(JSend.success({ user: result.user }));
    } catch (error) {
        console.error('Registration error:', error); // Log error for debugging
        if (error.message === 'Email already exists!') { // Updated error message
            return next(new ApiError(409, error.message));
        }
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

module.exports = { register };