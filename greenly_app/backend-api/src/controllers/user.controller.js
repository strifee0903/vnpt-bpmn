const usersService = require('../services/user.service');
const ApiError = require('../api-error');
const JSend = require('../jsend');
const { validationResult } = require('express-validator');
const sendMail = require('../helpers/sendMail');

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
            u_avt: req.file ? `/public/uploads/${req.file.filename}` : '/public/images/blank_avt.jpg',
        };
        const result = await usersService.registerUser(userData);

        // Send verification email
        const mailSubject = 'Mail Verification';
        const content = `<p>Hi ${req.body.u_name}, \nPlease <a href="https://example.com/mail-verification?token=${result.token}">Verify</a> your email.</p>`;
        await sendMail(req.body.u_email, mailSubject, content);

        return res
            .status(201)
            .set({ Location: `${req.baseUrl}/${result.user.u_id}` })
            .json(JSend.success({ message: 'The user has been registered! Please verify your email.', user: result.user }));
    } catch (error) {
        console.error('Registration error:', error);
        if (error.message === 'This email has been registered with us!') {
            return next(new ApiError(409, error.message));
        }
        if (error.message.includes('Failed to send email')) {
            return next(new ApiError(500, 'User registered, but failed to send verification email. Please try again later.'));
        }
        return next(new ApiError(500, 'System error, please try again later.'));
    }
}

module.exports = { register };